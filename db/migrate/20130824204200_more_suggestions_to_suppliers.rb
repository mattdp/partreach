class MoreSuggestionsToSuppliers < ActiveRecord::Migration
  def change
  	add_column :suppliers, :suggested_address, :text
  	add_column :suppliers, :suggested_url_main, :string
  end
end
