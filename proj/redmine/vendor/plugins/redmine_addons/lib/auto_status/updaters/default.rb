module AutoStatus
  module Updaters

    class DefaultIssueUpdater

      # current taks here
      def update(issue, current_user)
        return unless issue.parent.present?
        
        settings = RedmineAddons::Config.settings
        case issue.status_id
          when settings['status_ids']['in_progress']
            update_issue_status_to_in_progress issue.parent, current_user
          when settings['status_ids']['closed']
            update_issue_status_conditioned issue.parent, current_user
        end
      end


      private
    
      def update_issue_status_conditioned(issue, current_user)    
        if issue.parent.present?
          update_issue_status_to_audit_if_children_closed issue, current_user
        else
          update_issue_status_to_test_if_children_closed issue, current_user
        end
      end
      
      def update_issue_status_to_audit_if_children_closed(issue, current_user)
        if_children_closed issue do |issue|
          update_status_and_author issue, RedmineAddons::Config.settings['status_ids']['audit'], issue.author_id, current_user
        end
      end
          
      def update_issue_status_to_test_if_children_closed(issue, current_user)
        if_children_closed issue do |issue|
          update_status_and_author issue, RedmineAddons::Config.settings['status_ids']['testing'], issue.project.default_project_manager_id, current_user
        end
      end
              
      def if_children_closed(issue)
        should_change_parent_status = true
        issue.children.each do |child|
          should_change_parent_status = (child.status_id == RedmineAddons::Config.settings['status_ids']['closed'])
          break unless should_change_parent_status
        end
      
        yield(issue) if should_change_parent_status    
      end

      # non idea's parent goes to "in progress"
      # if one of its children goes to "in progress"
      def update_issue_status_to_in_progress(issue, current_user)
        return if issue.tracker_id == RedmineAddons::Config.settings['tracker_ids']['idea']
        
        update_status issue, RedmineAddons::Config.settings['status_ids']['in_progress'], current_user
        update_issue_status_to_in_progress(issue.parent, current_user) if issue.parent.present?
      end

      def update_status(issue, status_id, current_user)
        settings = RedmineAddons::Config.settings
        
        changer = AutoStatus::IssueChanger.new issue, current_user
        changer.params['done_date'] = Time.now if issue.status_id == settings['status_ids']['in_progress'] && [settings['status_ids']['audit'].to_s, settings['status_ids']['testing'].to_s].include?(status_id.to_s)
        changer.params['status_id'] = status_id
        changer.params['accept_date'] = Time.now if status_id == settings['status_ids']['in_progress']
        changer.change
      end

      def update_status_and_author(issue, status_id, assigned_to_id, current_user)
        settings = RedmineAddons::Config.settings
        
        changer = AutoStatus::IssueChanger.new issue, current_user

        changer.params['done_date'] = Time.now if issue.status_id == settings['status_ids']['in_progress'] && [settings['status_ids']['audit'].to_s, settings['status_ids']['testing'].to_s].include?(status_id.to_s)
        changer.params['status_id'] = status_id
        changer.params['accept_date'] = Time.now if status_id == settings['status_ids']['in_progress']
        changer.params['assigned_to_id'] = assigned_to_id
        changer.change
      end

    end

  end
end