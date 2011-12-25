class AddStartDateEndDateIsClosedToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :start_pr_date, :datetime
    add_column :projects, :end_pr_date, :datetime
    add_column :projects, :is_pr_closed, :integer,  :default=> 0
  end

  def self.down
    remove_column :projects, :start_pr_date
    remove_column :projects, :end_pr_date
    remove_column :projects, :is_closed
  end
end
