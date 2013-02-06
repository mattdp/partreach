class AddOptionalsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :name, :string
    add_column :orders, :deadline, :date
    add_column :orders, :supplier_message, :text
  end
end
