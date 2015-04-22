class ChangeAddressToLocationStringInProviders < ActiveRecord::Migration
  def change
    rename_column :providers, :address, :location_string
  end
end
