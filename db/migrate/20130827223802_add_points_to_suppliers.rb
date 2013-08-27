class AddPointsToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :points, :integer
  end
end
