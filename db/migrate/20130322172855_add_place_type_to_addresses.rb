class AddPlaceTypeToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :place_type, :string
  end
end
