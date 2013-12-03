class AddCountryAndStateToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :country_id, :integer
    add_column :addresses, :state_id, :integer
  end
end
