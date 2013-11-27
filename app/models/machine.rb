# == Schema Information
#
# Table name: machines
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  manufacturer_id :integer
#

class Machine < ActiveRecord::Base

	has_many :owners
	has_many :suppliers, :through => :owners
	belongs_to :manufacturer

	validates :name, presence: true
	validates_presence_of :manufacturer
	validates_uniqueness_of :name, :scope => :manufacturer_id

	def formatted_name
		return "#{self.manufacturer.name} #{self.name}"
	end
	
end
