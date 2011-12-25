module Babylon2QueriesHelperPatch

  def Babylon2QueriesHelperPatch.patch_queries_helper
    unless QueriesHelper.instance_methods(true).include?('column_content_without_babylon2')
      QueriesHelper.module_eval do
        def column_content_with_babylon2(column, issue)
          value = column.value(issue)
          case value.class.name
          when 'Fixnum', 'Float'
            if column.name == :done_ratio
              #return h(value.to_s) + '%'
              return lsx_progress_bar(value, :width => '80px')
            end
          end
          column_content_without_babylon2(column, issue)
        end
        alias_method_chain  :column_content, :babylon2

        def lsx_progress_bar(pcts, options={})
          pcts = [pcts, pcts] unless pcts.is_a?(Array)
          pcts = pcts.collect(&:round)
          pcts[1] = pcts[1] - pcts[0]
          pcts << (100 - pcts[1] - pcts[0])
          width = options[:width] || '100px;'
          legend = options[:legend] || ''
          p_label = "<span id=\"percent_a\"><span id=\"percent_b\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#{pcts[0]}%</span></span>"
          p_label_closed =(pcts[0] > 0 ? p_label : "" )
          p_label_todo =(pcts[2] > 0 && pcts[0] <= 0 ? p_label : "" )
          content_tag('table',
            content_tag('tr',
              (pcts[0] > 0 ? content_tag('td', p_label_closed, :style => "width: #{pcts[0]}%;", :class => 'closed') : '') +
                (pcts[1] > 0 ? content_tag('td', '', :style => "width: #{pcts[1]}%;", :class => 'done') : '') +
                (pcts[2] > 0 ? content_tag('td', p_label_todo, :style => "width: #{pcts[2]}%;", :class => 'todo') : '')
            ), :class => 'progress', :style => "width: #{width};")  +
            content_tag('p', legend, :class => 'pourcent')
        end
      end
    end
  end

end