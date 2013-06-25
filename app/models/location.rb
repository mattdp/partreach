# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  country       :string(255)
#  zip           :string(255)
#  location_name :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Location < ActiveRecord::Base
	attr_accessible :country, :zip, :location_name

	validates :country, presence: true
	validates :zip, presence: true
	validates :location_name, presence: true

end
