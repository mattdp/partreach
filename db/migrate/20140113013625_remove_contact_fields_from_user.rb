class RemoveContactFieldsFromUser < ActiveRecord::Migration
  def change
  	remove_column :users, :email
  	remove_column :users, :phone
  	remove_column :users, :name
  end
end
