# == Schema Information
#
# Table name: leads
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  email_valid      :boolean          default(TRUE)
#  email_subscribed :boolean          default(TRUE)
# 

class Lead < ActiveRecord::Base
  attr_accessible :email, :email_valid, :email_subscribed

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, presence: true, length: {minimum: 2}, \
  					format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
end
