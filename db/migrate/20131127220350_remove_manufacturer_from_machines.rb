class RemoveManufacturerFromMachines < ActiveRecord::Migration
  def change
  	remove_column :machines, :manufacturer
  end
end
