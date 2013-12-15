class AddInternalNotesToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :internal_notes, :text
  end
end
