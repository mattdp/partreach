class AddColumnsShownToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :columns_shown, :string
  end
end
