# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  phone            :string(255)
#  email            :string(255)
#  notes            :text
#  contactable_id   :integer
#  contactable_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Contact < ActiveRecord::Base
	belongs_to :contactable, polymorphic: true

	validates :contactable_id, presence: true
	validates :contactable_type, presence: true
end
