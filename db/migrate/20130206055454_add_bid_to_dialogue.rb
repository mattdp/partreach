class AddBidToDialogue < ActiveRecord::Migration
  def change
    add_column :dialogues, :bid, :integer
  end
end
