class CreateTableOptions < ActiveRecord::Migration
  def self.up
    create_table :table_options do |t|
      t.integer :user_id, :null => false
      t.string :table_name, :null => false
      t.string :option_name
      t.string :option_type
      t.string :value
      t.integer :field_order
    end
  end

  def self.down
    drop_table :table_options
  end
end