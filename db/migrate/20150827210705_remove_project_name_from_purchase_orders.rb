class RemoveProjectNameFromPurchaseOrders < ActiveRecord::Migration
  def change
  	remove_column :purchase_orders, :project_name
  end
end
