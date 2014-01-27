class AddMaterialToOrderGroups < ActiveRecord::Migration
  def change
    add_column :order_groups, :material, :string
  end
end
