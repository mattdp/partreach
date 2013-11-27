# == Schema Information
#
# Table name: manufacturers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Manufacturer < ActiveRecord::Base

	has_many :machines

	validates :name, presence: true, uniqueness: { case_sensitive: false }
	
end
