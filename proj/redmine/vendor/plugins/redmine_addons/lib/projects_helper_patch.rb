require_dependency 'projects_helper'
 
module ProjectsHelperPatch

   def self.included(base)
       base.send(:include, InstanceMethods)
       base.class_eval do
           unloadable
           alias_method_chain :project_settings_tabs, :redmine_specific_addons
       end
   end

   module InstanceMethods

       def project_settings_tabs_with_redmine_specific_addons
           tabs = project_settings_tabs_without_redmine_specific_addons
           tabs.push({ :name => 'redmine_specific_addons',
                       :action => :some_action,
                       :partial => 'projects/settings/redmine_specific_addons_settings',
                       :label => :project_settings_tab_label })
           return tabs
       end

   end

end