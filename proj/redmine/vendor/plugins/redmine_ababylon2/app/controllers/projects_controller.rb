require 'redmine'
require_dependency 'projects_controller'

class ProjectsController < ApplicationController
  before_filter :find_project, :except => [ :index, :list, :new, :create, :copy, :set_new_babylon2_field ]
  before_filter :authorize, :except => [ :index, :list, :new, :create, :copy, :archive, :unarchive, :destroy, :set_new_babylon2_field]
  #before_filter :clear_session_dates, :only => [ :new ]
  after_filter :clear_session_dates, :only => [ :create ]

  def set_new_babylon2_field
    time = ( params[:click_button]=='set' ? DateTime.parse(params[:myDate]) : nil )
    if params[:field] == 'end_pr_date'
      session[:end_pr_date] = time
    else
      session[:start_pr_date] = time
    end
    render :update do |page|
      page.replace_html "new_project_dates",:partial=>"projects/new_project_dates"
      if params[:field] == 'end_pr_date'
        page.replace_html "set_calendar_to", :partial=>"calendar/calendar", :locals => { :calendar_type => 'ajax',:clear_time => true, :form_name => 'calendar_form_totime', :time_obj => time, :hidden => true, :field => 'end_pr_date', :clear_action=>'set_new_babylon2_field' }
        page.replace_html "end_date_in_f", :partial=>"calendar/calendar", :locals => { :calendar_type => 'ajax',:clear_time => true, :form_name => 'calendar_form_totime', :time_obj => time, :clear_text=>"-", :field => 'end_pr_date', :clear_action=>'set_new_babylon2_field' }#, :hidden => true }
      else
        page.replace_html "set_calendar_from", :partial=>"calendar/calendar", :locals => { :calendar_type => 'ajax', :clear_time => true, :form_name => 'calendar_form_fromtime', :time_obj => time, :hidden => true, :field => 'start_pr_date', :clear_action=>'set_new_babylon2_field' }
        page.replace_html "start_date_in_f", :partial=>"calendar/calendar", :locals => { :calendar_type => 'ajax', :clear_time => true, :form_name => 'calendar_form_fromtime', :time_obj => time, :clear_text=>"-" , :field => 'start_pr_date', :clear_action=>'set_new_babylon2_field'}#, :hidden => true }
      end
    end
  end

  def clear_session_dates
    session[:start_pr_date] = nil
    session[:end_pr_date] = nil
  end

end