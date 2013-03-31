class DefaultForRecommendedInDialogues < ActiveRecord::Migration
  def change
    change_column :dialogues, :recommended, :boolean, :default => false
  end
end
