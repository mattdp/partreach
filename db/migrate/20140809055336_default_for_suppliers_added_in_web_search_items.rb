class DefaultForSuppliersAddedInWebSearchItems < ActiveRecord::Migration
  def up
    WebSearchItem.where(suppliers_added: nil).update_all(suppliers_added: 0)
    change_column :web_search_items, :suppliers_added, :integer, :default => 0
  end
  def down
    change_column :web_search_items, :suppliers_added, :integer
  end
end
