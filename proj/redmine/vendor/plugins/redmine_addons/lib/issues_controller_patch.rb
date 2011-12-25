require_dependency 'issues_controller'
 
module IssuesControllerPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      alias_method_chain :update, :redmine_addons
      alias_method_chain :bulk_edit, :redmine_addons
      alias_method_chain :bulk_update, :redmine_addons
      alias_method_chain :update_issue_from_params, :redmine_addons
      alias_method_chain :copy_subissue, :redmine_addons
    end
  end

  module InstanceMethods

    def copy_subissue_with_redmine_addons
      @allowed_projects = []
      # find projects to which the user is allowed to move the issue
      if User.current.admin?
        # admin is allowed to move issues to any active (visible) project
        @allowed_projects = Project.find(:all, :conditions => Project.visible_by(User.current))
      else
        User.current.memberships.each {|m| @allowed_projects << m.project if (m.respond_to?(:roles) ? m.roles.detect {|r| r.allowed_to?(:edit_parent)} : m.role.allowed_to?(:edit_parent)) }
      end
      @target_project = @allowed_projects.detect {|p| p.id.to_s == params[:new_project_id]} if params[:new_project_id]
      @target_project ||= @project
      @trackers = @target_project.trackers
      if request.post?
        p_issue = @issues.first
        new_tracker = params[:new_tracker_id].blank? ? p_issue.tracker : @target_project.trackers.find_by_id(params[:new_tracker_id])
       
        i2 = Issue.new
        i2.subject = params[:new_subject]
        i2.project = @target_project
        i2.author = User.current
        i2.created_on = Time.now
        i2.start_date = Time.now
        i2.assigned_to_id = params[:new_assigned_to_id] if params[:new_assigned_to_id]
        i2.tracker = new_tracker
        i2.description = params[:new_description]
        i2.priority_id = params[:new_priority_id]
        i2.start_date = params[:new_start_date]
        i2.auditor_id = params[:new_auditor_id]
        i2.due_date = params[:new_due_date]
        i2.status = IssueStatus.default
        if i2.save && i2.move_to_child_of(p_issue)
          flash[:notice] = l(:notice_successful_create)
        else
          #i2.errors.detect{|e| l(e[1])} * ","
          flash[:error] = l(:notice_failed_to_create_subissue)
        end
      
        redirect_to :controller => 'issues', :action => 'show', :id => @issues[0].id
        return
      end
      render :layout => false if request.xhr?
    end

    def bulk_update_with_redmine_addons
      statuses = Hash.new
      done_ratios = Hash.new
      
      settings = RedmineAddons::Config.settings
      if @issues.size == 1
        params[:issue][:assigned_to_id] = @issues[0].author_id if @issues[0].status_id == settings['status_ids']['in_progress'] && params['issue']['status_id'].to_s == settings['status_ids']['audit'].to_s
        params[:issue][:done_date] = Time.now if @issues[0].status_id == settings['status_ids']['in_progress'] && [settings['status_ids']['audit'].to_s, settings['status_ids']['testing'].to_s].include?(params['issue']['status_id'].to_s)
        params[:issue][:accept_date] = Time.now if params[:issue][:status_id].to_s == settings['status_ids']['in_progress'].to_s
      end
      
      @issues.each do |issue|
        statuses[issue.id] = issue.status_id
        done_ratios[issue.id] = issue.done_ratio
      end
      
      bulk_update_without_redmine_addons

      require 'auto_status/updater'
      updater = AutoStatus::Updater.new

      @issues.each do |issue|
        status_id_changed = (issue.status_id != statuses[issue.id])
        done_ratio_changed = (issue.done_ratio != done_ratios[issue.id])
        
        updater.update_status_by_status(issue, User.current) if status_id_changed
        updater.update_status_by_done_ratio(issue, User.current) if done_ratio_changed
      end
    end

    def update_with_redmine_addons
      if params[:kick_button_pressed] == '1'
        kick_assignee
        redirect_back_or_default({:action => 'show', :id => @issue})
      else
        settings = RedmineAddons::Config.settings
        params[:issue][:assigned_to_id] = @issue.author_id if @issue.status_id == settings['status_ids']['in_progress'] && params['issue']['status_id'].to_s == settings['status_ids']['audit'].to_s
        params[:issue][:done_date] = Time.now if @issue.status_id == settings['status_ids']['in_progress'] && [settings['status_ids']['audit'].to_s, settings['status_ids']['testing'].to_s].include?(params['issue']['status_id'].to_s)
        params[:issue][:accept_date] = Time.now if settings['status_ids']['in_progress'].to_s == params['issue']['status_id'].to_s && @issue.status_id.to_s != params['issue']['status_id'].to_s
                    
        if_issue_changed :update do |issue, current_user, status_id_changed, done_ratio_changed|
          require 'auto_status/updater'
          updater = AutoStatus::Updater.new

          updater.update_status_by_status(issue, current_user) if status_id_changed
          updater.update_status_by_done_ratio(issue, current_user) if done_ratio_changed
        end
      end
    end

    def bulk_edit_with_redmine_addons
      if params[:redmine_specific_addons]
        redmine_addons_fields_params
      else
        bulk_edit_without_redmine_addons
      end
    end    
    

    def update_issue_from_params_with_redmine_addons
      if params[:reject_button_pressed] == '1'
        reject_issue
      elsif params[:accept_button_pressed] == '1'
        accept_issue
      end
      
      settings = RedmineAddons::Config.settings
      params[:issue][:assigned_to_id] = @issue.author_id if @issue.status_id == settings['status_ids']['in_progress'] && params[:issue][:status_id] == settings['status_ids']['audit']
      
      @issue.estimated_hours = params[:issue][:estimated_hours] if params[:issue].present? && params[:issue][:estimated_hours].present?
      update_issue_from_params_without_redmine_addons
    end

    
    private

    def kick_assignee
      return unless @issue.assigned_to.present?
      
      if @issue.assigned_to.present? && @issue.assigned_to.jabber.present?
        message = "Вас пнул #{User.current.name} из задачи № #{@issue.id} #{@issue.subject} #{issue_url(@issue)} - #{params[:kick_button_message].present? ? params[:kick_button_message] : 'нажал кнопку "пнуть"'}"
      
        require 'jabber_robot'
        notificator = JabberRobot.new
        notificator.notify @issue.assigned_to.jabber, message      
      end
    end

    def if_issue_changed(method_name)
      before_status_id = @issue.status_id
      before_done_ratio = @issue.done_ratio
      send("#{method_name.to_s}_without_redmine_addons".to_sym)
      after_status_id = @issue.status_id
      after_done_ratio = @issue.done_ratio
      
      status_id_changed = (after_status_id != before_status_id)
      done_ratio_changed = (after_done_ratio != before_done_ratio)
      
      yield(@issue, User.current, status_id_changed, done_ratio_changed) if status_id_changed or done_ratio_changed
    end

    def redmine_addons_fields_params
      @allowed_statuses = @issues[0].new_statuses_allowed_to(User.current)
      @assignables = @projects.map(&:assignable_users).inject{|memo,a| memo & a}
      @priorities = IssuePriority.active
      
      render :json => [@issues[0].id, @allowed_statuses, @assignables, @priorities], :status => 200
    end
    
    def reject_issue
      settings = RedmineAddons::Config.settings
      
      reason = params[:notes].dup
      params[:notes] = "Ваша задача отклонена по причине: #{reason}" 
      
      if @issue.status_id == settings['status_ids']['new'] || @issue.status_id == settings['status_ids']['in_progress']
        params[:issue][:status_id] = settings['status_ids']['rejected']
        params[:issue][:assigned_to_id] = @issue.author_id
      else
        prev_status_id, prev_assignee_id = find_prev_status_id_and_prev_assignee_id(@issue)
        
        params[:issue][:status_id] = prev_status_id
        params[:issue][:assigned_to_id] = prev_assignee_id
      end
      
      # send notification via jabber
      if @issue.author.jabber.present?
        message = "Ваша #{issue_url(@issue)} задача № #{@issue.id} - #{@issue.subject} - отклонена по причине: #{reason}"
        
        require 'jabber_robot'
        notificator = JabberRobot.new
        notificator.notify @issue.author.jabber, message
      end
    end
    
    def find_prev_status_id_and_prev_assignee_id(issue)
      prev_status_id = issue.status_id
      prev_assignee_id = issue.assigned_to_id
      
      prev_status_id_found = false
      prev_assignee_id_found = false
      
      issue.journals.reverse.each do |journal|
        unless prev_status_id_found
          status_detail = journal.details.find_by_prop_key('status_id')
          unless status_detail.nil?
            prev_status_id = status_detail.old_value
            prev_status_id_found = true
          end
        end
        
        unless prev_assignee_id_found
          assignee_detail = journal.details.find_by_prop_key('assigned_to_id')
          unless assignee_detail.nil?
            prev_assignee_id = assignee_detail.old_value
            prev_assignee_id_found = true
          end
        end
        
        break if prev_status_id_found && prev_assignee_id_found
      end
      
      return prev_status_id, prev_assignee_id
    end
    
    def accept_issue
      settings = RedmineAddons::Config.settings
      
      if @issue.status_id == settings['status_ids']['new']
        params[:issue][:accept_date] = Time.now unless @issue.accept_date.present?
        
        if @issue.tracker_id == settings['tracker_ids']['idea']
          params[:issue][:status_id] = settings['status_ids']['analysis']
          params[:issue][:assigned_to_id] = User.current.id
        else
          params[:issue][:status_id] = settings['status_ids']['in_progress']
        end
      end
    end

  end

end