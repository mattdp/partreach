class RemoveFieldsFromOrders < ActiveRecord::Migration
  def change
  	remove_column :orders, :quantity
  	remove_column :orders, :drawing_units 
  	# remove_column :orders, :drawing_file_name
  end
end
