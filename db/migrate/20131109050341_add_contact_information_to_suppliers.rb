class AddContactInformationToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :billing_contact_name, :string
    add_column :suppliers, :billing_contact_email, :string
    add_column :suppliers, :billing_contact_phone, :string
    add_column :suppliers, :billing_contact_method, :string
    add_column :suppliers, :billing_contact_address, :text

    add_column :suppliers, :contract_contact_name, :string
    add_column :suppliers, :contract_contact_email, :string
    add_column :suppliers, :contract_contact_phone, :string

    add_column :users, :phone, :string

    add_column :suppliers, :rfq_contact_name, :string 
    add_column :suppliers, :rfq_contact_notes, :string
  end
end
