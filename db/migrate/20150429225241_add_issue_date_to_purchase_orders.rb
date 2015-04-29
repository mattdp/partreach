class AddIssueDateToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :issue_date, :date
  end
end
