class AddCloseEmailBodyToDialogue < ActiveRecord::Migration
  def change
    add_column :dialogues, :close_email_body, :text
  end
end
