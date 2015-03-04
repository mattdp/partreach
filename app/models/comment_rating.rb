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
    if comment_rating.save
      # maintain denormalized count of total ratings and helpful ratings in Comment
      counters = {}
      counters[:ratings_count] = 1
      counters[:helpful_count] = 1 if helpful
      Comment.update_counters(comment_id, counters)
    end

    comment_rating.id
  end

end
