class RenameBlurbInSuppliers < ActiveRecord::Migration
  def change
  	rename_column :suppliers, :blurb, :description
  end
end
