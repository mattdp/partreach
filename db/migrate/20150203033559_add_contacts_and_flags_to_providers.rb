class AddContactsAndFlagsToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :tag_laser_cutting, :boolean, :default => false
    add_column :providers, :tag_cnc_machining, :boolean, :default => false

    add_column :providers, :contact_qq, :string
    add_column :providers, :contact_wechat, :string
    add_column :providers, :contact_phone, :string
    add_column :providers, :contact_email, :string
    add_column :providers, :contact_name, :string
    add_column :providers, :contact_role, :string

    add_column :providers, :verified, :boolean, :default => false

    add_column :providers, :city, :string
    add_column :providers, :address, :text
  end
end
