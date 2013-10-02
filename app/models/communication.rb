# == Schema Information
#
# Table name: communications
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  subtype     :string(255)
#  notes       :text
#  supplier_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Communication < ActiveRecord::Base

	belongs_to :supplier

	validates :supplier_id, presence: true
	validates :means_of_interaction, presence: true

end
