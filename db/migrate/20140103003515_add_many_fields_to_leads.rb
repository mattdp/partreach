class AddManyFieldsToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :source, :string, default: "manual"
    add_column :leads, :next_contact_date, :date
    add_column :leads, :next_contact_content, :string
    add_column :leads, :company, :string
    add_column :leads, :title, :string				
    add_column :leads, :notes, :text
  end
end
