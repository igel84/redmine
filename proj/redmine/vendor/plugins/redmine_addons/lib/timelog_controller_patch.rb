require_dependency 'timelog_controller'
 
module TimelogControllerPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      alias_method_chain :new, :redmine_addons
      alias_method_chain :create, :redmine_addons
    end
  end

  module InstanceMethods
    
    def new_with_redmine_addons
      if params[:done_field_time_entry]
        @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
        @time_entry.attributes = params[:time_entry]

        render :action => 'edit_with_redmine_addons', :layout => false
      else
        new_without_redmine_addons
      end
    end
    
    def create_with_redmine_addons
      if params[:done_field_time_entry]
        @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
        @time_entry.attributes = params[:time_entry]
    
        if @time_entry.save
          if params[:done_value].present?
            done_ratio_changed = (@issue.done_ratio != 100) && params[:done_value].to_s == '100'
          
            changer = AutoStatus::IssueChanger.new @issue, User.current
            changer.params['done_ratio'] = params[:done_value]
            @issue.force_time_entry_create
            changer.save
          
            if done_ratio_changed
              updater = AutoStatus::Updater.new
              updater.update_status_by_done_ratio(@issue, User.current) 
            end
          end
          
          flash[:notice] = l(:notice_successful_update)
          redirect_back_or_default :action => 'index', :project_id => @time_entry.project
        else
          render :action => 'edit_with_redmine_addons'
        end        
      else
        create_without_redmine_addons
      end
    end
    
  end

end