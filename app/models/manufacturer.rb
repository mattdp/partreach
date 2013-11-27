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

	has_many :machines, dependent: :destroy

	validates :name, presence: true, uniqueness: { case_sensitive: false }
	
	def self.create_or_reference_manufacturer(manufacturer_params)
		name = manufacturer_params[:name]
		manufacturer = Manufacturer.where("name = ?",name)
		if manufacturer.present?
			return manufacturer[0]
		else
			new_man = Manufacturer.create({name: name})
			return new_man if new_man
			return nil
		end
	end

end
