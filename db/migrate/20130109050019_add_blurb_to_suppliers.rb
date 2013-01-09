class AddBlurbToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :blurb, :string
  end
end
