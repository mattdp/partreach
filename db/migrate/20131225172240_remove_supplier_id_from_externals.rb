class RemoveSupplierIdFromExternals < ActiveRecord::Migration
  def change
  	remove_column :externals, :supplier_id
  end
end
