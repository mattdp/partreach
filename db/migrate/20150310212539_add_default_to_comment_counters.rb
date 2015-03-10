class AddDefaultToCommentCounters < ActiveRecord::Migration
  def change
    change_column_default(:comments, :ratings_count, 0)
    change_column_default(:comments, :helpful_count, 0)
  end
end

