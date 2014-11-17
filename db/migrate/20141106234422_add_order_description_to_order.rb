class AddOrderDescriptionToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :order_description, :text
  end
end
