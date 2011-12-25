require 'redmine'
require_dependency 'hooks'
require_dependency 'redmine_addons/config'

require 'dispatcher'

Dispatcher.to_prepare do
	IssuesHelper.send(:include, IssuesHelperPatch) unless IssuesHelper.included_modules.include? IssuesHelperPatch

  ProjectsHelper.send(:include, ProjectsHelperPatch) unless ProjectsHelper.included_modules.include? ProjectsHelperPatch

  Project.send(:include, ProjectPatch) unless Project.included_modules.include? ProjectPatch
  MembersController.send(:include, MembersControllerPatch) unless MembersController.included_modules.include? MembersControllerPatch

  IssuesController.send(:include, IssuesControllerPatch) unless IssuesController.included_modules.include? IssuesControllerPatch
  TimelogController.send(:include, TimelogControllerPatch) unless TimelogController.included_modules.include? TimelogControllerPatch
  
  User.send(:include, UserPatch) unless User.included_modules.include? UserPatch
  
  TimeEntry.send(:include, TimeEntryPatch) unless TimeEntry.included_modules.include? TimeEntryPatch
  
  Issue.send(:include, IssuePatch) unless Issue.included_modules.include? IssuePatch
  IssueObserver.send(:include, IssueObserverPatch) unless IssueObserver.included_modules.include? IssueObserverPatch
  
  Query.send(:include, QueryPatch) unless Query.included_modules.include? QueryPatch
end

Redmine::Plugin.register :redmine_redmine_specific_addons do
  name 'Redmine Specific Addons plugin'
  author 'Alexandr Borisov'
  description 'This is a plugin for Redmine wich adds specific functions.'
  version '0.0.1'
  author_url 'http://aishek.moikrug.ru/'
end