class AddDrawingUnitsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :drawing_units, :string
  end
end
