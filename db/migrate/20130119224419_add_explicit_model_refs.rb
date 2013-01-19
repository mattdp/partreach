class AddExplicitModelRefs < ActiveRecord::Migration
  def up
  	add_column :orders, :user_id, :integer
  	add_column :dialogues, :order_id, :integer
  	add_column :dialogues, :supplier_id, :integer
  	add_column :users, :address_id, :integer
  	add_column :suppliers, :address_id, :integer
  	remove_column :suppliers, :zipcode
  end

  def down
  	remove_column :orders, :user_id
  	remove_column :dialogues, :order_id
  	remove_column :dialogues, :supplier_id
  	remove_column :users, :address_id
  	remove_column :suppliers, :address_id
  	add_column :suppliers, :zipcode, :integer
  end
end
