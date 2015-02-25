# == Schema Information
#
# Table name: comments
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  provider_id   :integer
#  comment_type  :string(255)
#  payload       :text
#  created_at    :datetime
#  updated_at    :datetime
#  overall_score :integer          default(0)
#  title         :string(255)
#

class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider 
  has_many :comment_ratings

  #comment_type should be "purchase_order", "factory_visit", or "comment"
  #score of 0 = didn't give a score. 1 low, 5 high

end
