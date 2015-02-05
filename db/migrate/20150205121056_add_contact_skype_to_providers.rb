class AddContactSkypeToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :contact_skype, :string
  end
end
