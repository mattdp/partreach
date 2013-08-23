class AddSuggestedServicesToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :suggested_services, :text
  end
end
