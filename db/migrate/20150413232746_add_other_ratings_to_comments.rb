class AddOtherRatingsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :cost_score, :integer, :default => 0
    add_column :comments, :quality_score, :integer, :default => 0
    add_column :comments, :speed_score, :integer, :default => 0
  end
end
