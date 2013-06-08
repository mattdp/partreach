class AddPVtoSuppliers < ActiveRecord::Migration
  def change
  	add_column :suppliers, :profile_visible, :boolean, :default => false
  end
end
