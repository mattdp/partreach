# == Schema Information
#
# Table name: machines
#
#  id                 :integer          not null, primary key
#  name               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  manufacturer_id    :integer
#  bv_height          :decimal(6, 2)
#  bv_width           :decimal(6, 2)
#  bv_length          :decimal(6, 2)
#  materials_possible :text
#  z_height           :string(255)
#  profile_visible    :boolean          default(TRUE)
#  name_for_link      :string(255)
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

	def self.proper_name_for_link(name)
		Supplier.proper_name_for_link(name)
	end
	
end
