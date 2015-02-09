class AddOverallScoreToComments < ActiveRecord::Migration
  def change
    add_column :comments, :overall_score, :integer, :default => 0
  end
end
