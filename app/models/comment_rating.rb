# == Schema Information
#
# Table name: comment_ratings
#
#  id         :integer          not null, primary key
#  comment_id :integer
#  user_id    :integer
#  helpful    :boolean
#  created_at :datetime
#  updated_at :datetime
#

class CommentRating < ActiveRecord::Base
  belongs_to :comment
  belongs_to :user

  def self.add_rating(comment_id, user, helpful)
    comment_rating = CommentRating.new(comment_id: comment_id, user: user, helpful: helpful)
    saved_ok = comment_rating.save
    
    # maintain denormalized count of total ratings and helpful ratings in Comment
    helpful_increment = ( helpful ? 1 : 0 )
    Comment.update_counters(comment_id, ratings_count: 1, helpful_count: helpful_increment)

    saved_ok
  end

end
