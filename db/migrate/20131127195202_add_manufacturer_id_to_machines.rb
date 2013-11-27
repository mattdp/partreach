class AddManufacturerIdToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :manufacturer_id, :integer
  end
end
