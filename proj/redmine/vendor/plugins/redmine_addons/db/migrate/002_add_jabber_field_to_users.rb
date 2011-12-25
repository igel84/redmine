class AddJabberFieldToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :jabber, :string
  end

  def self.down
    remove_column :users, :jabber
  end
end
