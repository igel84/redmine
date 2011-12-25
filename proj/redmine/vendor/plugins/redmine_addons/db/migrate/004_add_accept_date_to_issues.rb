class AddAcceptDateToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :accept_date, :datetime
  end

  def self.down
    remove_column :issues, :accept_date
  end
end
