require_dependency 'issue'
 
module IssuePatch

  def self.included(base)
     base.send(:include, InstanceMethods)
     base.class_eval do
       unloadable
       alias_method_chain :validate, :redmine_specific_addons
       alias_method_chain :save_issue_with_child_records, :redmine_specific_addons
       alias_method_chain :new_statuses_allowed_to, :redmine_addons
       
       belongs_to :auditor, :class_name => 'User', :foreign_key => 'auditor_id'
       
       safe_attributes 'done_date', 'accept_date', 'auditor_id'
     end
  end
  
  module InstanceMethods
        
    # Returns an array of status that user is able to apply
    def new_statuses_allowed_to_with_redmine_addons(user, include_default=false)
      statuses = new_statuses_allowed_to_without_redmine_addons(user, include_default)
      if status_id == RedmineAddons::Config.settings['status_ids']['in_progress'] && done_ratio < 100
        statuses.reject! {|status| (status.id != RedmineAddons::Config.settings['status_ids']['rejected']) && (status.id != RedmineAddons::Config.settings['status_ids']['in_progress'])}
      end
      
      statuses
    end

    def validate_with_redmine_specific_addons
      validate_without_redmine_specific_addons
      
      settings = RedmineAddons::Config.settings
      
      if status_id_was == settings['status_ids']['in_progress'] && status_id_changed? && done_ratio < 100
        errors.add(:status_id, :invalid_status) unless status_id == RedmineAddons::Config.settings['status_ids']['rejected']
      end
      
      if done_date && done_date < start_date && !(status_id_was == settings['status_ids']['in_progress'] && status_id == settings['status_ids']['audit'])
        errors.add :done_date, :too_soon_done_date
      end
      
      if done_ratio_changed? && done_ratio == 100
        errors.add :done_ratio, :status_not_in_progress if status_id != RedmineAddons::Config.settings['status_ids']['in_progress']
        
        self.errors.add(:done_ratio, :no_time_entry) if !@time_entry_created
      end
    end

    def force_time_entry_create
      @time_entry_created = true
    end

    # Saves an issue, time_entry, attachments, and a journal from the parameters
    # Returns false if save fails
    def save_issue_with_child_records_with_redmine_specific_addons(params, existing_time_entry=nil)
      Issue.transaction do
        @time_entry_created = false
        if params[:time_entry] && (params[:time_entry][:hours].present? || params[:time_entry][:comments].present?) && User.current.allowed_to?(:log_time, project)
          @time_entry = existing_time_entry || TimeEntry.new
          @time_entry.project = project
          @time_entry.issue = self
          @time_entry.user = User.current
          @time_entry.spent_on = Date.today
          @time_entry.attributes = params[:time_entry]
          @time_entry_created = true
          self.time_entries << @time_entry
        end

        if valid?
          attachments = Attachment.attach_files(self, params[:attachments])

          attachments[:files].each {|a| @current_journal.details << JournalDetail.new(:property => 'attachment', :prop_key => a.id, :value => a.filename)}
          # TODO: Rename hook
          Redmine::Hook.call_hook(:controller_issues_edit_before_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
          begin
            if save
              # TODO: Rename hook
              Redmine::Hook.call_hook(:controller_issues_edit_after_save, { :params => params, :issue => self, :time_entry => @time_entry, :journal => @current_journal})
            else
              raise ActiveRecord::Rollback
            end
          rescue ActiveRecord::StaleObjectError
            attachments[:files].each(&:destroy)
            errors.add_to_base l(:notice_locking_conflict)
            raise ActiveRecord::Rollback
          end
        end
      end
    end
      
  end

end