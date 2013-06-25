class CreateLocations < ActiveRecord::Migration
  def change
  	create_table :locations do |t|
  		t.string :country
  		t.string :zip
  		t.string :location_name

  		t.timestamps
  	end
  end
end
