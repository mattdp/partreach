class AddSuggestedSuppliersToOrders < ActiveRecord::Migration
  def change
  	add_column :orders, :suggested_suppliers, :string
  end
end
