class AddMaterialmessageToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :material_message, :text
  end
end
