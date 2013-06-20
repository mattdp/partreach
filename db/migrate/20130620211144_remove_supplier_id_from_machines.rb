class RemoveSupplierIdFromMachines < ActiveRecord::Migration
  def change
  	remove_column :machines, :supplier_id
  end
end
