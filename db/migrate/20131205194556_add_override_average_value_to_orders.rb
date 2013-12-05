class AddOverrideAverageValueToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :override_average_value, :decimal
  end
end
