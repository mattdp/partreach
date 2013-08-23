class AddPreferencesToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :suggested_preferences, :text
    add_column :suppliers, :preferences, :text
  end
end
