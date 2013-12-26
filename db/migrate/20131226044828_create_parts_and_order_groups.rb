class CreatePartsAndOrderGroups < ActiveRecord::Migration
  def change
    create_table :parts do |t|
    	t.integer :order_group_id

    	t.integer :quantity
    	t.string :name

    	t.timestamps
    end

    create_table :order_groups do |t|
    	t.integer :order_id

    	t.string :name

    	t.timestamps
    end
  end
end
