require_dependency 'time_entry'
 
module TimeEntryPatch

  def self.included(base)
    base.class_eval do
      after_create {|entry|

        settings = RedmineAddons::Config::settings
        issue = entry.issue
        if issue.status_id == settings['status_ids']['new']
          Issue.update_all ["status_id = ?, accept_date = ?", settings['status_ids']['in_progress'], Time.now], ["id = ?", issue.id]
        end        
      
      }
    end
  end

end