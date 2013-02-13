class ChangeSupplierUrLs < ActiveRecord::Migration
  def change
  	rename_column :suppliers, :url, :url_main
  	add_column :suppliers, :url_materials, :string
  end
end
