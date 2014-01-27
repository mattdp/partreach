class AddNextContactPersonToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :next_contactor, :string
  end
end
