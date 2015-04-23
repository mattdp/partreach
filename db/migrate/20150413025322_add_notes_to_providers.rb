class AddNotesToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :organization_private_notes, :text
    add_column :providers, :external_notes, :text
  end
end
