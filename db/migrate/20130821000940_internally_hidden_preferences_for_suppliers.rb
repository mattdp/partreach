class InternallyHiddenPreferencesForSuppliers < ActiveRecord::Migration
  def change
  	rename_column :suppliers, :preferences, :internally_hidden_preferences
  end
end
