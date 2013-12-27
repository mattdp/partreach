class AddUnitsToExternals < ActiveRecord::Migration
  def change
    add_column :externals, :units, :string
  end
end
