class RemoveAddressIdFromSuppliers < ActiveRecord::Migration
  def change
  	remove_column :suppliers, :address_id
  end
end
