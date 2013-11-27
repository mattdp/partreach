# == Schema Information
#
# Table name: machines
#
#  id              :integer          not null, primary key
#  manufacturer    :string(255)
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
	validates :manufacturer, presence: true

	def formatted_name
		return "#{self.manufacturer} #{self.name}"
	end
	
end
