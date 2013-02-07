class AddFlagToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :is_over_without_winner, :boolean
  end
end
