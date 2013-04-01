class AddNextstepsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :next_steps, :text
  end
end
