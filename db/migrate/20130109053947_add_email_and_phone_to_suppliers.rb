class AddEmailAndPhoneToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :email, :string
    add_column :suppliers, :phone, :string
  end
end
