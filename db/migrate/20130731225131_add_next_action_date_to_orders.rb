class AddNextActionDateToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :next_action_date, :date
  end
end
