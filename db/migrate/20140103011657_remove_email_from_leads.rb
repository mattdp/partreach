class RemoveEmailFromLeads < ActiveRecord::Migration
  def change
  	remove_column :leads, :email
  end
end
