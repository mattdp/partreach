class CreateGeographies < ActiveRecord::Migration
  def change
    create_table :geographies do |t|

    	t.string :level
    	t.string :short_name
    	t.string :long_name
    	t.string :name_for_link
    	t.integer :containing_geography

    	t.timestamps
    end
  end
end
