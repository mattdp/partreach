class AddNamesToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :first_name, :string
    add_column :leads, :last_name, :string
  end
end
