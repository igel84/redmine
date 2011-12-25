require 'auto_status/updaters/idea'
require 'auto_status/updaters/default'
require 'auto_status/issue_changer'

module AutoStatus
  
  class Updater    
    def update_status_by_done_ratio(issue, current_user)
      settings = RedmineAddons::Config.settings
      
      case issue.status_id
        when settings['status_ids']['in_progress']
          if issue.done_ratio == 100
            update_status issue, settings['status_ids']['audit'], current_user
            update_status_by_status issue, current_user
          end
        when settings['status_ids']['new']
          if issue.done_ratio > 0
            update_status issue, settings['status_ids']['in_progress'], current_user
            update_status_by_status issue, current_user
          end
      end
    end
    
    def update_status_by_status(issue, current_user)
      concrete_updater = nil
      case issue.tracker_id
        when RedmineAddons::Config.settings['tracker_ids']['idea'] then          
          concrete_updater = AutoStatus::Updaters::IdeaIssueUpdater.new
        else
          concrete_updater = AutoStatus::Updaters::DefaultIssueUpdater.new
      end
      concrete_updater.update(issue, current_user) unless concrete_updater.nil?
    end
    
    
    private
    
    def update_status(issue, status_id, current_user)
      settings = RedmineAddons::Config.settings
      
      changer = AutoStatus::IssueChanger.new issue, current_user
      changer.params['status_id'] = status_id
      if status_id == settings['status_ids']['audit'] && issue.status_id == settings['status_ids']['in_progress']
        changer.params['assigned_to_id'] = issue.author_id
        changer.params['done_date'] = Time.now
      end
      changer.change
    end
        
  end
  
end