class TableOption < ActiveRecord::Base

  def self.get_columns_for_user_table(user,tablename)
    option_type="col_name"
    TableOption.find(:all, :conditions=>["table_name=? AND user_id=? AND option_type=?", tablename, user.id, option_type ], :order=>'field_order').map{|to| to.value}
  end

  def self.get_group_by_for_user_table(user, tablename)
    option_type="group_by"
    option = TableOption.find(:first, :conditions=>["table_name=? AND user_id=? AND option_type=?", tablename, user.id, option_type ])
    option ? option.value  : nil
  end

  def self.set_group_by_for_user_table(user, tablename, value)
    option_type="group_by"
    option = TableOption.find(:first, :conditions=>["table_name=? AND user_id=? AND option_type=?", tablename, user.id, option_type ])
    option = TableOption.new(:table_name=>tablename, :user_id=>user.id, :option_type=> option_type ) unless option
    option.value = value
    option.save
  end

  def self.get_columns_sizes_for_user_table(user,tablename)
    option_type="col_width"
    options = TableOption.find(:all, :conditions=>["table_name=? AND user_id=? AND option_type=?", tablename, user.id, option_type ])
    options.inject(Hash.new){|res,option|
      res[option.option_name] = option.value
      res
    }
  end

  def self.set_column_order_for_user_table(user, tablename, col_orders)
    col_type="col_name"
    fields_for_delete = get_columns_for_user_table(user,'issues') - col_orders.keys
    TableOption.destroy_all(["table_name=? AND user_id=? AND option_type=? AND value IN(?)", 'issues', user.id, col_type ,fields_for_delete])
    col_orders.keys.each do |field_name|
      option_col = TableOption.find(:first, :conditions=>["table_name=? AND user_id=? AND option_type=? AND value=?", tablename, user.id, col_type ,field_name])
      option_col = TableOption.new(:table_name=>tablename, :user_id=>user.id, :option_type=>col_type,:value=>field_name ) unless option_col
      option_col.field_order = col_orders[field_name]
      option_col.save
    end
  end
  
  def self.set_column_sizes_for_user_table(user, tablename, col_sizes)
    width_type="col_width"
    col_sizes.keys.each do |field_name|
      if col_sizes[field_name] && col_sizes[field_name]>0 # set column width
        option_size = TableOption.find(:first, :conditions=>["table_name=? AND user_id=? AND option_type=? AND option_name=?", tablename, user.id, width_type ,field_name])
        if option_size
          option_size.value = col_sizes[field_name]
        else
          option_size = TableOption.new(:table_name=>tablename, :user_id=>user.id, :option_type=>width_type, :option_name=>field_name, :value=>col_sizes[field_name])
        end
        option_size.save
      end
    end

    TableOption.destroy_all(["table_name=? AND user_id=? AND option_type=? AND Not(option_name IN(?))", tablename, user.id, width_type ,col_sizes.keys])
  end


end