class AddBoolsToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :further_negotiation, :boolean
    add_column :dialogues, :won, :boolean
  end
end
