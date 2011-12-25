require 'auto_status/issue_changer'

module AutoStatus
  module Updaters

    class IdeaIssueUpdater

      def update(issue, current_user)
        if issue.status_id == RedmineAddons::Config.settings['status_ids']['closed'] and issue.parent.present?
          update_issue_status_to_testing_if_children_closed issue.parent, current_user
        end
      end


      private
    
      # close parent issue
      # if all children have status 'closed'
      def update_issue_status_to_testing_if_children_closed(issue, current_user)    
        settings = RedmineAddons::Config.settings
        
        should_change_parent_status = true
        issue.children.each do |child|
          should_change_parent_status = (child.status_id == settings['status_ids']['closed'])
          break unless should_change_parent_status
        end
      
        change_issue_fields issue, current_user if should_change_parent_status
      end
      
      def change_issue_fields(issue, current_user)
        settings = RedmineAddons::Config.settings
        
        changer = AutoStatus::IssueChanger.new issue, current_user
        changer.params['done_date'] = Time.now if issue.status_id == settings['status_ids']['in_progress']
        changer.params['status_id'] = settings['status_ids']['testing']
        changer.params['assigned_to_id'] = issue.project.default_project_manager_id
        changer.change
      end

    end

  end
end