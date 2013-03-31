class AddRecommendedToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :recommended, :boolean
  end
end
