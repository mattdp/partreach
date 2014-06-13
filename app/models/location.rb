# == Schema Information
#
# Table name: locations
#
#  id            :integer          not null, primary key
#  country       :string(255)
#  zip           :string(255)
#  location_name :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Location < ActiveRecord::Base

  validates :country, presence: true
  validates :zip, presence: true
  validates :location_name, presence: true

end
