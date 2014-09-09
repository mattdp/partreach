class AddCcEmailToContact < ActiveRecord::Migration
  def up
    add_column :contacts, :cc_emails, :text, default: ''
    Contact.update_all(cc_emails: '')
  end

  def down
    remove_column :contacts, :cc_emails
  end
end
