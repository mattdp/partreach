class AddPriorityToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :priority, :string
  end
end
