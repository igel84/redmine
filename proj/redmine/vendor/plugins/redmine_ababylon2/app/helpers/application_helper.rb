
module ApplicationHelper

  def babylon2_page_header_title#_with_babylon2
    textlen=0
    if @project.nil? || @project.new_record?
      textlen = h(Setting.app_title).chars.to_a.length
      return h(Setting.app_title)
    else
      b = []
      ancestors = (@project.root? ? [] : @project.ancestors.visible.all)
      if ancestors.any?
        root = ancestors.shift
        textlen += h(root).chars.to_a.length
        b << link_to_project(root, {:jump => current_menu_item}, :class => 'root')
        if ancestors.size > 2
          b << '&#8230;'
          ancestors = ancestors[-2, 2]
        end
        textlen += ancestors.inject(textlen){|res, p| res + h(p).chars.to_a.length}
        b += ancestors.collect {|p| link_to_project(p, {:jump => current_menu_item}, :class => 'ancestor') }
      end
      b << h(@project)
    end
    if @issue
      @issue.ancestors.each do |a_issue|
        b << link_to_issue(a_issue,  :class => 'ancestor')
        textlen += "#{a_issue.tracker} ##{a_issue.id}".chars.to_a.length
        textlen += ": #{h a_issue.subject}".chars.to_a.length if a_issue.subject
      end
      b << link_to_issue(@issue,  :class => 'ancestor')
      textlen += "#{@issue.tracker} ##{@issue.id}".chars.to_a.length
      textlen += ": #{h @issue.subject}".chars.to_a.length if @issue.subject
    end
    if b
      textlen += (b.size-1)*3
      @babylon2_page_header_title_length = textlen
      #b <<("  LEN:#{textlen}")
      b.join(' &#187; ')
    end
    #b << '&#8230;' #...
    #"Once:" + ActiveSupport::Dependencies.load_once_paths.to_s + " <br><br>Load:"  + ActiveSupport::Dependencies.load_paths.to_s
  end


  def babylon2_page_header_size
    babylon2_page_header_title unless @babylon2_page_header_title_length
    return 5 unless @babylon2_page_header_title_length
    return 1 if @babylon2_page_header_title_length > 110
    return 2 if @babylon2_page_header_title_length > 80
    return 3 if @babylon2_page_header_title_length > 67
    return 4 if @babylon2_page_header_title_length > 50
    return 5
  end
 
end
