require 'redmine'
require 'dispatcher'

require 'projectstreeview_projects_helper_patch'# projects_tree_view
# begin redmine_addons
require 'issues_helper_patch'
# end redmine_addons
require 'babylon2_account_controller_patch'
require 'babylon2_projects_controller_patch'
require 'babylon2_issues_controller_patch'
require 'babylon2_queries_helper_patch'
require 'babylon2_menu_helper_patch'
require 'babylon2_project_patch'
require 'babylon2_user_patch'
require 'babylon2_users_controller_patch'


require_dependency 'redmine_babylon2/hooks'

#ActionController::Base.view_paths.unshift File.join(directory, 'app/views')

Dispatcher.to_prepare  do
  ProjectsHelper.send(:include, ProjectstreeviewProjectsHelperPatch)# projects_tree_view
  #rm_addons begin
  IssuesHelper.send(:include, IssuesHelperPatch) unless IssuesHelper.included_modules.include? IssuesHelperPatch
  #rm_addons END
  ProjectsController.send(:include, Babylon2ProjectsControllerPatch) # set end & start date AJAX
  IssuesController.send(:include, Babylon2IssuesControllerPatch) #deny new issues for closed projects
  Babylon2QueriesHelperPatch::patch_queries_helper # readiness % in digits
  Babylon2MenuHelperPatch::patch_menu_helper  # del tab NewIssue for closed projects
  AccountController.send(:include, Babylon2AccountControllerPatch)unless AccountController.included_modules.include? Babylon2AccountControllerPatch # redirect to My page after login
  Project.send(:include, Babylon2ProjectPatch)unless Project.included_modules.include?(Babylon2ProjectPatch) # get start & end dates
  User.send(:include, Babylon2UserPatch)unless User.included_modules.include?(Babylon2UserPatch) # stavka rights
  UsersController.send(:include, Babylon2UsersControllerPatch) #check stavka edit rights while edit user
end


Redmine::AccessControl.map do |map|
  map.permission :edit_project_dates, {:projects => [ :set_babylon2_field]}, :require => :member
end

Redmine::Plugin.register :redmine_ababylon2 do
  name 'Redmine Babylon2 '
  author 'Lamanik Dzmitry'
  description 'Babylon2 plugin for Redmine'
  version '0.0.1'
  # menu :top_menu, :example_link, "http://www.example.com" #add menu item
  delete_menu_item :top_menu, :home  # удалить домашнюю страницу
  delete_menu_item :project_menu, :activity
  delete_menu_item :project_menu, :overview
end

