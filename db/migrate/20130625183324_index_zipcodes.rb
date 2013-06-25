class IndexZipcodes < ActiveRecord::Migration
  def change
  	#reverse this when have multiple countries with locations
  	add_index :locations, :zip, :unique => true
  end
end
