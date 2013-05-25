class RemoveSupplierCategory < ActiveRecord::Migration
  def change
  	remove_column :suppliers, :category
  end
end
