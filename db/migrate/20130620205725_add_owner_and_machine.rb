class AddOwnerAndMachine < ActiveRecord::Migration
  def change
    create_table :owners do |t|
    	t.integer :supplier_id
    	t.integer :machine_id

      t.timestamps
    end

    create_table :machines do |t|
    	t.integer :supplier_id
    	t.string :manufacturer
    	t.string :name

    	t.timestamps
    end
    
  end
end
