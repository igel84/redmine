class AddAuditorIdToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :auditor_id, :integer
  end

  def self.down
    remove_column :issues, :auditor_id
  end
end
