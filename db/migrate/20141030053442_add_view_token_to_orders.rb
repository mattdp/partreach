class AddViewTokenToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :view_token, :string
  end
end
