class AddSourceToSupplier < ActiveRecord::Migration
  def change
    add_column :suppliers, :source, :string
  end
end
