#require_dependency 'issues_helper' 

module IssuesHelperPatch
  def self.included(base) # :nodoc:    
    base.send(:include, InstanceMethods)     
    base.class_eval do      
      unloadable
      alias_method_chain :sidebar_queries, :category
      alias_method_chain :show_detail, :redmine_addons
    end
  end

  module InstanceMethods    
    
    def show_detail_with_redmine_addons(detail, no_html=false)
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
    
    def sidebar_queries_with_category
      unless @sidebar_queries
        # User can see public queries and his own queries
        visible = ARCondition.new(["is_public = ? OR user_id = ?", true, (User.current.logged? ? User.current.id : 0)])
        # Project specific queries and global queries
        visible << (@project.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", @project.id])
        @sidebar_queries = Query.find(:all, 
                                      :order => "name ASC",
                                      :conditions => visible.conditions)
      end
      @sidebar_queries
    end

    def group_issues(issues, query)
      issues = issues.select{|i| i.ancestors.size == 0 || ((issues + i.ancestors).uniq.size == issues.size+i.ancestors.size)}
      if query.group_by && query.group_by != ""
        issues.group_by {|i| column_plain_content(query.group_by.to_sym, i) }.sort()
      else
        { "" => issues }
      end
    end

    def issue_outline(issue, issue_list, level, g)
      content = ""
      (1..level-1).each do |l|
        class_name = 'space'
        class_name = 'outline-3' if (g[l-1] <= 1)
        content += content_tag 'td', '&nbsp;', :class => class_name
      end
      ind = (issue == issue_list.last)? 2 : (issue == issue_list.first ? 0 : 1)
      class_name = case ind
        when 0; level == 1 ? "outline-4" : "outline-2"
        when 1; "outline-2"
        when 2; issue == issue_list.first && level == 1 ? "outline-5" : "outline-1"
        else "space"
      end
      class_name = class_name + " has-childs open" unless issue.leaf?
      content += content_tag 'td', '&nbsp;', :class => class_name, :onclick => issue.leaf? ? "" : "toggle_sub(" + issue.id.to_s + ");"
      content
    end

    def column_header_with_spans(column)
      column.name == :subject ? "<th><span class='has-childs open' onclick='toggle_all();'>&nbsp;&nbsp;&nbsp;&nbsp;</span></th>"+sort_header_tag(column.name.to_s, :caption => column.caption, :default_order => column.default_order, :colspan => 9) :
        column_header(column)
    end
    
    def column_plain_content(column_name, issue)
      column = @query.available_columns.find{|c| c.name == column_name}
  		if column.nil?
  			issue.project.parent ? issue.project.parent.name : issue.project.name if column_name == :main_project
  		else
  			if column.is_a?(QueryCustomFieldColumn)
  				cv = issue.custom_values.detect {|v| v.custom_field_id == column.custom_field.id}
  				show_value(cv)
  			else
  				value = issue.send(column.name.to_s)
  				if value.is_a?(Date)
  					format_date(value)
  				elsif value.is_a?(Time)
  					format_time(value)
  				elsif column.name == :done_ratio
            value.to_s.rjust(3) << '%'
  				else
  					value.to_s
  				end
  			end
  		end
    end

  end
end