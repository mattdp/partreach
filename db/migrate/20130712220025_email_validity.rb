class EmailValidity < ActiveRecord::Migration
  def change
  	add_column :users, :email_valid, :boolean, :default => true
  	add_column :leads, :email_valid, :boolean, :default => true
  	add_column :users, :email_subscribed, :boolean, :default => true
  	add_column :leads, :email_subscribed, :boolean, :default => true
  end
end
