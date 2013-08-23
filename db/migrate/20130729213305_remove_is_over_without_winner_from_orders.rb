class RemoveIsOverWithoutWinnerFromOrders < ActiveRecord::Migration
  def change
  	remove_column :orders, :is_over_without_winner
  end
end
