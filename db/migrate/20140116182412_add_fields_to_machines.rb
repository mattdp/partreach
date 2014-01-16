class AddFieldsToMachines < ActiveRecord::Migration
  def change
  	add_column :machines, :bv_height, :decimal, precision: 6,  scale: 2
   	add_column :machines, :bv_width, :decimal, precision: 6, scale: 2
  	add_column :machines, :bv_length, :decimal, precision: 6, scale: 2
  	add_column :machines, :materials_possible, :text
  	add_column :machines, :z_height, :string
  end
end
