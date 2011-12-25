class CreateStavkaRights < ActiveRecord::Migration
  def self.up
    create_table :stavka_rights do |t|
      t.integer :user_id, :null => false
      t.integer :stavka_user_id, :null => false
      t.integer :right, :null => false
    end
    add_index :stavka_rights, :user_id
  end

  def self.down
    remove_index :stavka_rights, :user_id
    drop_table :stavka_rights
  end
end