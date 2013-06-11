class AddNflToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :name_for_link, :string
  end
end
