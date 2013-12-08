class CreateFilter < ActiveRecord::Migration
  def change
    create_table :filters do |t|
    	t.integer :geography_id
    	t.integer :has_tag_id
    	t.integer :has_not_tag_id

    	t.string :name
    	
    	t.timestamps
    end
  end
end
