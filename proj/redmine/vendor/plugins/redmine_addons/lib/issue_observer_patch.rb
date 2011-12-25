require_dependency 'issue_observer'
 
module IssueObserverPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:include, ActionController::UrlWriter)
    base.class_eval do
      unloadable
      alias_method_chain :after_create, :redmine_addons
    end
  end
  
  module InstanceMethods
    
    def after_create_with_redmine_addons(issue)
      after_create_without_redmine_addons(issue)
      notify_assigned(issue) if issue.assigned_to.present? && issue.assigned_to.jabber.present?
    end
    
    def after_save(issue)
      notify_assigned(issue) if issue.assigned_to_id_changed? && issue.assigned_to.present? && issue.assigned_to.jabber.present?
    end
    
    
    private
    
    def notify_assigned(issue)
      message = "Вас назначили ответственным по задаче № #{issue.id} - #{issue.subject} #{issue_url(issue, :host => Setting.host_name)}"
      
      require 'jabber_robot'
      notificator = JabberRobot.new
      notificator.notify issue.assigned_to.jabber, message
    end
    
  end

end
