# == Schema Information
#
# Table name: comments
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  provider_id  :integer
#  comment_type :string(255)
#  payload      :text
#  created_at   :datetime
#  updated_at   :datetime
#

class Comment < ActiveRecord::Base

  belongs_to :user
  belongs_to :provider 

end
