class AddEmailFieldsToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :email_valid, :boolean
    add_column :contacts, :email_subscribed, :boolean
  end
end
