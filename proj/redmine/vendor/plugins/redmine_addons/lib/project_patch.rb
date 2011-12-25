require_dependency 'project'
 
module ProjectPatch

  def self.included(base)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods

    def update_default_product_manager_id(value)
      Project.update_all("default_product_manager_id = #{value.to_s}", "id = #{id.to_s}")
    end

    def update_default_project_manager_id(value)
      Project.update_all("default_project_manager_id = #{value.to_s}", "id = #{id.to_s}")
    end
    
  end

end