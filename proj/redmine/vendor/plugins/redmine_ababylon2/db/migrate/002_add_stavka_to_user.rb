class AddStavkaToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :stavka, :float,  :default=> 0
  end

  def self.down
    remove_column :users, :stavka
  end
end
