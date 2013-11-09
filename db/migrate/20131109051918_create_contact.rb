class CreateContact < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
    	t.string :name
    	t.string :phone
    	t.string :email
    	t.text :notes
    	t.references :contactable, polymorphic: true
    	t.timestamps
    end
  end
end
