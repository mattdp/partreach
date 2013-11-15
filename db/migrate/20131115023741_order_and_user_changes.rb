class OrderAndUserChanges < ActiveRecord::Migration
  def change
  	add_column :orders, :stated_experience, :string
  	add_column :orders, :stated_priority, :string
  	add_column :orders, :stated_manufacturing, :string
  	change_column :orders, :deadline, :string
  	add_column :users, :phone, :string
  end
end
