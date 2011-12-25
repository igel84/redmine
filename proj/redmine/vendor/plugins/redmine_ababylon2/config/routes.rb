#require 'redmine_babylon2/utils'

ActionController::Routing::Routes.draw do |map|

  map.home '', :controller => 'my', :action=>'page'

  map.connect 'projects/:id/set_babylon2_field', :controller => 'projects', :action => 'set_babylon2_field'



  #map.connect "projects/:project_id/charts/#{name}/:action", :controller => controller

  #  RedmineCharts::Utils.controllers_for_routing do |name, controller|
  #    map.connect "projects/:project_id/charts/#{name}/:action", :controller => controller
  #  end

  #  RedmineCharts::Utils.controllers_for_routing do |name, controller|
  #    map.connect "projects/:project_id/charts/#{name}/:action", :controller => controller
  #  end

  #map.connect 'attachments/download_inline/:id/:filename',  :controller => 'attachments', :action => 'download_inline', :id => /\d+/, :filename => /.*/
  #map.resources :my_page_tabs, :member => { :move => :post }
end