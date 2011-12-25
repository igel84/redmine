require 'tree'
require 'action_view/helpers/capture_helper'

module Babylon2MenuHelperPatch

  def Babylon2MenuHelperPatch.patch_menu_helper
    unless Redmine::MenuManager::MenuHelper.instance_methods(true).include?('render_menu_node_without_babylon2')
      Redmine::MenuManager::MenuHelper.module_eval do

        def render_menu_node_with_babylon2(node, project=nil)
          if node.hasChildren? || !node.child_menus.nil?
            return render_menu_node_with_children(node, project)
          else
            caption, url, selected = extract_node_details(node, project)
            if node.html_options[:class]=="new-issue" && project.is_pr_closed && project.is_pr_closed==1
              return nil # "Pcl:" + project.is_pr_closed.to_s
            else
              return content_tag('li', render_single_menu_node(node, caption, url, selected))
            end
          end
        end

        alias_method_chain  :render_menu_node, :babylon2

      end
    end
  end

end
