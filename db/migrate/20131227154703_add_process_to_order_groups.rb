class AddProcessToOrderGroups < ActiveRecord::Migration
  def change
  	add_column :order_groups, :process, :string
  end
end
