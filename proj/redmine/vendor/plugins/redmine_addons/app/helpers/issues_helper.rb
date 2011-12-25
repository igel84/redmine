module IssuesHelper

  def show_detail(detail, no_html=false)
    case detail.property
    when 'attr'
      field = detail.prop_key.to_s.gsub(/\_id$/, "")
      label = l(("field_" + field).to_sym)
      case
      when ['accept_date', 'done_date'].include?(detail.prop_key)
        value = format_time(detail.value.to_time) if detail.value
        old_value = format_time(detail.old_value.to_time) if detail.old_value

      when ['due_date', 'start_date', 'accept_date'].include?(detail.prop_key)
        value = format_date(detail.value.to_date) if detail.value
        old_value = format_date(detail.old_value.to_date) if detail.old_value
    
      when ['project_id', 'status_id', 'tracker_id', 'auditor_id', 'assigned_to_id', 'priority_id', 'category_id', 'fixed_version_id'].include?(detail.prop_key)
        value = find_name_by_reflection(field, detail.value)
        old_value = find_name_by_reflection(field, detail.old_value)
    
      when detail.prop_key == 'estimated_hours'
        value = "%0.02f" % detail.value.to_f unless detail.value.blank?
        old_value = "%0.02f" % detail.old_value.to_f unless detail.old_value.blank?
    
      when detail.prop_key == 'parent_id'
        label = l(:field_parent_issue)
        value = "##{detail.value}" unless detail.value.blank?
        old_value = "##{detail.old_value}" unless detail.old_value.blank?
    
      when detail.prop_key == 'is_private'
        value = l(detail.value == "0" ? :general_text_No : :general_text_Yes) unless detail.value.blank?
        old_value = l(detail.old_value == "0" ? :general_text_No : :general_text_Yes) unless detail.old_value.blank?
      end
    when 'cf'
      custom_field = CustomField.find_by_id(detail.prop_key)
      if custom_field
        label = custom_field.name
        value = format_value(detail.value, custom_field.field_format) if detail.value
        old_value = format_value(detail.old_value, custom_field.field_format) if detail.old_value
      end
    when 'attachment'
      label = l(:label_attachment)
    end
    call_hook(:helper_issues_show_detail_after_setting, {:detail => detail, :label => label, :value => value, :old_value => old_value })
    
    label ||= detail.prop_key
    value ||= detail.value
    old_value ||= detail.old_value
    
    unless no_html
      label = content_tag('strong', label)
      old_value = content_tag("i", h(old_value)) if detail.old_value
      old_value = content_tag("strike", old_value) if detail.old_value and (!detail.value or detail.value.empty?)
      if detail.property == 'attachment' && !value.blank? && a = Attachment.find_by_id(detail.prop_key)
        # Link to the attachment if it has not been removed
        value = link_to_attachment(a)
      else
        value = content_tag("i", h(value)) if value
      end
    end
    
    if detail.property == 'attr' && detail.prop_key == 'description'
      s = l(:text_journal_changed_no_detail, :label => label)
      unless no_html
        diff_link = link_to 'diff',
          {:controller => 'journals', :action => 'diff', :id => detail.journal_id, :detail_id => detail.id},
          :title => l(:label_view_diff)
        s << " (#{ diff_link })"
      end
      s
    elsif !detail.value.blank?
      case detail.property
      when 'attr', 'cf'
        if !detail.old_value.blank?
          l(:text_journal_changed, :label => label, :old => old_value, :new => value)
        else
          l(:text_journal_set_to, :label => label, :value => value)
        end
      when 'attachment'
        l(:text_journal_added, :label => label, :value => value)
      end
    else
      l(:text_journal_deleted, :label => label, :old => old_value)
    end
  end

end
