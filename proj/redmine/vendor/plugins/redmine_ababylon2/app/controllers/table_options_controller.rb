class TableOptionsController < ApplicationController
  unloadable
  layout 'modal2'#false 
  include QueriesHelper


  def edit_options
    retrieve_query
    @query.column_names = TableOption.get_columns_for_user_table(User.current,"issues")
    @query.group_by = TableOption.get_group_by_for_user_table(User.current,"issues")
    @col_sizes = TableOption.get_columns_sizes_for_user_table(User.current,"issues");
  end


  def update
    columns = params[:c] || []
    col_sizes = {}
    col_orders = {}
    (1..columns.length).each do |i|
      col_orders[columns[i-1]] = i
      col_sizes[columns[i-1]] = ( params['td_width'+i.to_s] ? params['td_width'+i.to_s].gsub!(/\D/,'').to_i : 0 )
    end
    TableOption.set_column_sizes_for_user_table(User.current,'issues', col_sizes)
    TableOption.set_column_order_for_user_table(User.current,'issues', col_orders)
    TableOption.set_group_by_for_user_table(User.current,'issues', (params[:group_by] ? params[:group_by] : "") )
    #render :text=> params.inspect + ' col sizes'+ col_sizes.inspect  + ' col_o' + col_orders.inspect
    render :inline=>"<script>opener.location.reload();self.close();</script>"
  end


  def change_cols_number
    @col_sizes = TableOption.get_columns_sizes_for_user_table(User.current,"issues");
    sel_options = params[:sel_options].split(" _AND_ ")-[""];
    render :update do |page|
      page.replace_html "resize_table",  :partial=>"table_cols_resize", :locals=>{:sel_options => sel_options}
    end
  end

end
