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
#  cost_score        :integer          default(0)
#  quality_score     :integer          default(0)
#  speed_score       :integer          default(0)
#

class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider, touch: true
  belongs_to :purchase_order
  has_many :comment_ratings

  #comment_type should be "purchase_order", "factory_visit", or "comment"
  #score of 0 = didn't give a score. 1 low, 5 high

  def untouched?
    return false if (self.payload.present? or self.any_ratings_given?)
    events = Event.where("target_model = 'Comment' AND target_model_id = ?",self.id)
    return false if events.map{|e| e.has_been_touched_by_user?}.any?
    return true
  end

  def self.score_symbols
    [:overall_score, :cost_score, :quality_score, :speed_score]
  end

  def any_ratings_given?
    scores = Comment.score_symbols.map{|ss| self.send(ss)}
    return scores.any?{|s| s != 0}
  end

  def rating_by(user)
    CommentRating.where(comment: self).where(user: user).first
  end

  def self.verbose_type(comment_type)
    case comment_type
    when "comment"
      return "comment"
    when "factory_visit"
      return "factory visit comment"
    when "purchase_order"
      return "purchase order comment"
    else
      return "unknown comment type"
    end
  end

end
