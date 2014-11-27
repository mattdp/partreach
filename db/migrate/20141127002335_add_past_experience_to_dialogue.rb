class AddPastExperienceToDialogue < ActiveRecord::Migration
  def change
    add_column :dialogues, :past_experience, :string
  end
end
