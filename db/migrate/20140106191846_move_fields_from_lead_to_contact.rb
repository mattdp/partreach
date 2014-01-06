class MoveFieldsFromLeadToContact < ActiveRecord::Migration
  def change
  	remove_column :leads, :first_name
  	remove_column :leads, :last_name
  	remove_column :leads, :title
  	remove_column :leads, :company
  	add_column :contacts, :first_name, :string
  	add_column :contacts, :last_name, :string
  	add_column :contacts, :title, :string
  	add_column :contacts, :company, :string
  end
end
