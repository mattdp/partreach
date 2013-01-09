class RemoveZipcodeFromSuppliers < ActiveRecord::Migration
  def up
    remove_column :suppliers, :zipcode
  end

  def down
    add_column :suppliers, :zipcode, :string
  end
end
