class AddToAddresses < ActiveRecord::Migration
  def change
  	add_column :addresses, :country, :string
  	add_column :addresses, :notes, :text
  end
end
