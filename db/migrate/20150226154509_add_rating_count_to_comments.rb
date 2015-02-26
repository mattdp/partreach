class AddRatingCountToComments < ActiveRecord::Migration
  def change
    add_column :comments, :ratings_count, :integer
    add_column :comments, :helpful_count, :integer
  end
end
