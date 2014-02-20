# encoding: utf-8

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
	has_one :external, :as => :consumer, :dependent => :destroy
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

	def self.name_cleaner(name)
		return name.tr("®™","").strip
	end

	def create_or_change_external(url)
		external = self.external
		external = External.new(consumer_type: "Machine", consumer_id: self.id) if external.nil?
		external.url = url
		external.save
	end

	#need to include the rest of the parameters
	def self.create_or_reference_machine(machine_params)
		name = Machine.name_cleaner(machine_params[:name])
		manufacturer_id = machine_params[:manufacturer_id]
		machine = Machine.where("name = ? and manufacturer_id = ?",name, manufacturer_id)
		if machine.present?
			return machine[0]
		else
			new_machine = Machine.create({name: name, name_for_link: Machine.proper_name_for_link(name), manufacturer_id: manufacturer_id})
			return new_machine if new_machine
			return nil
		end
	end
	
end
