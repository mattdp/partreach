class AddHowFoundUsToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :how_found_us, :text
  end
end
