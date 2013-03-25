class AddCategoryToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :category, :string, :default => "none"
  end
end
