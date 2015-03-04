class AddRatingCountToComments < ActiveRecord::Migration
  def change
    add_column :comments, :ratings_count, :integer
    add_column :comments, :helpful_count, :integer

    reversible do |dir|
      dir.up do
        Comment.update_all ratings_count: 0, helpful_count: 0
      end
    end

  end
end
