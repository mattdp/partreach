class RemoveOrderIdFromDialogues < ActiveRecord::Migration
  def change
  	remove_column :dialogues, :order_id
  end
end
