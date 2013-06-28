class CreateExternals < ActiveRecord::Migration
  def change
  	create_table :externals do |t|
  		t.integer :supplier_id
  		t.string :url

  		t.timestamps
  	end
  end
end
