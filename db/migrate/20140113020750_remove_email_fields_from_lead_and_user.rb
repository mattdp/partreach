class RemoveEmailFieldsFromLeadAndUser < ActiveRecord::Migration
  def change
		remove_column :users, :email_valid
		remove_column :users, :email_subscribed
		remove_column :leads, :email_valid
		remove_column :leads, :email_subscribed
  end
end
