class AddCrmToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :next_contact_date, :date
    add_column :suppliers, :next_contact_content, :string
  end
end
