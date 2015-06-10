class UploaderImprovements < ActiveRecord::Migration
  def change
    add_column :providers, :name_in_purchasing_system, :string
    add_column :purchase_orders, :id_in_purchasing_system, :integer
  end
end
