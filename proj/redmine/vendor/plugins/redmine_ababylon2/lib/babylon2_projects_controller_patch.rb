#require_dependency 'projects_controller'
module Babylon2ProjectsControllerPatch

  def self.included(base_class)
    base_class.send(:include, ProjectsControllerInstanceMethods)
    base_class.class_eval do
      #alias_method_chain  :create, :babylon2
    end
  end

  module ProjectsControllerInstanceMethods

    def set_babylon2_field
      time = ( params[:click_button]=='set' ? DateTime.parse(params[:myDate]) : nil )
      @project = Project.find(params[:id])
      unless @project
        redirect_to :back
        return
      end
      error_mes = 'Error'
      if params[:field] == 'end_pr_date'
        @project.end_pr_date = time
      else
        @project.start_pr_date = time
      end
      @success = @project.save
      @project.reload
      render :update do |page|
        #page.replace_html "test_lsx", "OK ZZZZZZZp:" +params.inspect
        page.replace_html "ajax_messages", :partial=>"ajax_messages", :locals => {:error_mes=>error_mes}
        page.replace_html "set_calendar_from", :partial=>"calendar/calendar",
            :locals => { :calendar_type => 'ajax', :clear_time => true, :form_name => 'calendar_form_fromtime', :time_obj => @project.start_pr_date, :hidden => true, :field => 'start_pr_date', :clear_action=>'set_babylon2_field'}
        page.replace_html "start_date_in_f", :partial=>"calendar/calendar", 
            :locals => { :calendar_type => 'ajax', :clear_time => true, :form_name => 'calendar_form_fromtime', :time_obj => @project.start_pr_date, :clear_text=>"Auto:" + @project.get_start_date_str, :field => 'start_pr_date', :clear_action=>'set_babylon2_field'}
        page.replace_html "set_calendar_to", :partial=>"calendar/calendar",
            :locals => { :calendar_type => 'ajax',:clear_time => true, :form_name => 'calendar_form_totime', :time_obj => @project.end_pr_date, :hidden => true, :field => 'end_pr_date', :clear_action=>'set_babylon2_field'}
        page.replace_html "end_date_in_f", :partial=>"calendar/calendar",
            :locals => { :calendar_type => 'ajax',:clear_time => true, :form_name => 'calendar_form_totime', :time_obj => @project.end_pr_date, :clear_text=>"Auto:" + @project.get_end_date_str, :field => 'end_pr_date', :clear_action=>'set_babylon2_field'}
      end
    end


  end


end