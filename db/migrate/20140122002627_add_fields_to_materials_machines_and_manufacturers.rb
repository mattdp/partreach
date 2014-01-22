class AddFieldsToMaterialsMachinesAndManufacturers < ActiveRecord::Migration
  def change
  	add_column :machines, :profile_visible, :boolean, default: true
  	add_column :manufacturers, :profile_visible, :boolean, default: true
  	add_column :machines, :name_for_link, :string
  	add_column :manufacturers, :name_for_link, :string
  end
end
