# == Schema Information
#
# Table name: comments
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  provider_id       :integer
#  comment_type      :string(255)
#  payload           :text
#  created_at        :datetime
#  updated_at        :datetime
#  overall_score     :integer          default(0)
#  title             :string(255)
#  ratings_count     :integer          default(0)
#  helpful_count     :integer          default(0)
#  purchase_order_id :integer
#

class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider
  belongs_to :purchase_order
  has_many :comment_ratings

  #comment_type should be "purchase_order", "factory_visit", or "comment"
  #score of 0 = didn't give a score. 1 low, 5 high

  def rating_by(user)
    CommentRating.where(comment: self).where(user: user).first
  end
end
