#require_dependency 'issues_controller'
module Babylon2IssuesControllerPatch

  def self.included(base_class)
    base_class.send(:include, IssuesControllerInstanceMethods)
    base_class.class_eval do
      alias_method_chain  :new, :babylon2
    end
  end

  module IssuesControllerInstanceMethods

    def new_with_babylon2
      if @project.is_pr_closed && @project.is_pr_closed==1
        #render :text=>params.inspect + @project.id.inspect
        flash[:error]=l(:deny_add_issue_project_is_closed)
        redirect_to  :controller=>'projects', :action=>'index'
      else
        new_without_babylon2
      end
    end

  end


end