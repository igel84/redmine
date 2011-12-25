module Hooks
  class ControllerTimelogAvailableCriteriasHook < Redmine::Hook::ViewListener
    render_on :view_issues_index_bottom, :partial => 'hooks/redmine_addons/view_issues_index_bottom'
    
    def controller_issues_bulk_edit_before_save(context={ })
      context[:issue].done_ratio = context[:params][:issue][:done_ratio] if context[:params][:issue][:done_ratio]
      context[:issue].start_date = context[:params][:issue][:start_date] if context[:params][:issue][:start_date]
      context[:issue].due_date = context[:params][:issue][:due_date] if context[:params][:issue][:due_date]
      context[:issue].estimated_hours = context[:params][:issue][:estimated_hours] if context[:params][:issue][:estimated_hours]
      context[:issue].priority_id = context[:params][:issue][:priority_id] if context[:params][:issue][:priority_id]
    end    
  end
end