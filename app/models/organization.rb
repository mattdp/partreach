# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Organization < ActiveRecord::Base
  has_many :teams
  has_many :providers
  has_many :tags
end
