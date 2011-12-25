class AddDefaultProductManagerAndDefaultProjectManagerIdsToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :default_product_manager_id, :integer
    add_column :projects, :default_project_manager_id, :integer
  end

  def self.down
    remove_column :projects, :default_project_manager_id
    remove_column :projects, :default_product_manager_id
  end
end
