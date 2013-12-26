class AddOrderGroupIdToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :order_group_id, :integer
  end
end
