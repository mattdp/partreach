class RemoveContactInformationFromSuppliers < ActiveRecord::Migration
  def change
  	remove_column :suppliers, :phone
  	remove_column :suppliers, :email
  end
end
