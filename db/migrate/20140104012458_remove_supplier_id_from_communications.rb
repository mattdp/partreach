class RemoveSupplierIdFromCommunications < ActiveRecord::Migration
  def change
  	remove_column :communications, :supplier_id
  end
end
