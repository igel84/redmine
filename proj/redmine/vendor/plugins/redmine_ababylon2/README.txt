1. delete Projects_tree_view plugin
2. disable stylesheet.css from redmine_issues_group for table widths columns
  (comment in init.rb #render_on :view_layouts_base_html_head, :inline => "<%= stylesheet_link_tag 'stylesheet', :plugin => 'redmine_issues_group' %>")