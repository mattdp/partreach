class AddSuggestionsToSupplier < ActiveRecord::Migration
  def change
    add_column :suppliers, :suggested_description, :text
    add_column :suppliers, :suggested_machines, :text
  end
end
