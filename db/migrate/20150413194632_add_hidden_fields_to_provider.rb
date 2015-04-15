class AddHiddenFieldsToProvider < ActiveRecord::Migration
  def change
    add_column :providers, :import_warnings, :text
    add_column :providers, :supplybetter_private_notes, :text
  end
end
