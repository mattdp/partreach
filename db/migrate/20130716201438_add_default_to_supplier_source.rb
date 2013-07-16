class AddDefaultToSupplierSource < ActiveRecord::Migration
  def change
  	change_column :suppliers, :source, :string, :default => "manual"
  end
end
