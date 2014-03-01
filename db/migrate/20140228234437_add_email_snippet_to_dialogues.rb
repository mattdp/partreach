class AddEmailSnippetToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :email_snippet, :text
  end
end
