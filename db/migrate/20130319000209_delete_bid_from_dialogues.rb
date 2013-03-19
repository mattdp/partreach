class DeleteBidFromDialogues < ActiveRecord::Migration
  def change
  	remove_column :dialogues, :bid
  end
end