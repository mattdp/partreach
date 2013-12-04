class RemoveCountryAndStateFromAddresses < ActiveRecord::Migration
  def change
  	remove_column :addresses, :country
  	remove_column :addresses, :state
  end
end
