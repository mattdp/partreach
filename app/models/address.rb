# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  street     :string(255)
#  city       :string(255)
#  state      :string(255)
#  zip        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  place_id   :integer
#  place_type :string(255)
#  country    :string(255)
#  notes      :text
#

class Address < ActiveRecord::Base
  attr_accessible :city, :name, :state, :street, :zip, :country, :notes

  belongs_to :place, :polymorphic => true

  validates :place_id, presence: true
  validates :place_type, presence: true

  def self.all_countries
  	countries = []
  	Address.all.map {|a| countries << a.country}
  	countries = countries.uniq
  	countries.delete(nil) if countries.include?(nil)
  	return countries
  end

  def self.find_supplier_ids_by_country_and_state(country,state)
    addresses = Address.where("country = ? and state = ? and place_type = ?", \
      country, state, "Supplier")
    return [] if addresses == []
    suppliers = Supplier.find(addresses.map{|a| a.place_id})
  end

end
