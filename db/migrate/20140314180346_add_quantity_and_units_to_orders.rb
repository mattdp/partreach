class AddQuantityAndUnitsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :stated_quantity, :integer
    add_column :orders, :units, :string
  end
end
