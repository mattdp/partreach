class AddLeadTimeToPurchaseOrders < ActiveRecord::Migration
  def change
    add_column :purchase_orders, :lead_time_days, :integer
  end
end
