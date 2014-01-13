class AddDefaultToEmailFields < ActiveRecord::Migration
  def change
		change_column :contacts, :email_valid, :boolean, default: true
		change_column :contacts, :email_subscribed, :boolean, default: true  	
  end
end
