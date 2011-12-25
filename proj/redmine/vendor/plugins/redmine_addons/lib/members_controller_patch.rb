require_dependency 'members_controller'
 
module MembersControllerPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      unloadable
      alias_method_chain :edit, :redmine_specific_addons
    end
  end

  module InstanceMethods

    def edit_with_redmine_specific_addons
      processed = false
      if request.post? and (params[:member][:default_project_manager_id] || params[:member][:default_product_manager_id])
        @project.update_default_project_manager_id(params[:member][:default_project_manager_id]) if params[:member][:default_project_manager_id]
        @project.update_default_product_manager_id(params[:member][:default_product_manager_id]) if params[:member][:default_product_manager_id]

        respond_to do |format|
          format.html { redirect_to :controller => 'projects', :action => 'settings', :tab => 'redmine_specific_addons', :id => @project }
          format.js {
            render(:update) {|page|
              page.visual_effect(:highlight, "r_member-#{@member.id}")
            }
          }
        end

        processed = true
      end      
      
      edit_without_redmine_specific_addons unless processed
    end

  end

end