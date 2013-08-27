class AddDefaultZeroPointsToSuppliers < ActiveRecord::Migration
  def change
  	change_column :suppliers, :points, :integer, :default => 0
  end
end
