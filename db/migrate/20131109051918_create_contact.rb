class CreateContact < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
    	t.string :name
    	t.string :phone
    	t.string :email
        t.string :method
    	t.text :notes
        t.string :type
    	t.timestamps
    end
  end
end
