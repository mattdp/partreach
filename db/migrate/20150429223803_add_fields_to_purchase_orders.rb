class AddFieldsToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :description, :text
    add_column :purchase_orders, :project_name, :string
  end
end
