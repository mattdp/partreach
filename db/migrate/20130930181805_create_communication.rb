class CreateCommunication < ActiveRecord::Migration
  def change
    create_table :communications do |t|
			t.string :type
      t.string :subtype
      t.text :notes
      t.integer :supplier_id

      t.timestamps    	
    end
  end
end