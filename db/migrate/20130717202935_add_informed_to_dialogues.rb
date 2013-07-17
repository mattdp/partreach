class AddInformedToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :informed, :boolean
  end
end
