class Communication < ActiveRecord::Base

	belongs_to :supplier

	validates :supplier_id, presence: true
	validates :type, presence: true

end