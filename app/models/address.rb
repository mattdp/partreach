# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
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

  belongs_to :place, :polymorphic => true

  validates :place_id, presence: true
  validates :place_type, presence: true

  def readable
    return "#{self.street} #{self.city} #{self.state} #{self.zip} #{self.country}"
  end

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

  def self.geo_name_transform(attribute,input,symbol)
    if attribute == "country"
      hash = COUNTRIES_HASH
    elsif attribute == "us_state"
      hash = US_STATE_HASH
    else
      return false
    end

    #states always upcase
    return hash[input].upcase if symbol == :to_shortform
    return hash.map{ |k,v| k if v == input }.compact[0] if symbol == :to_longform  
    return false
  end

  def self.us_states_of_visible_profiles
    states = []
    suppliers = Supplier.visible_profiles
    suppliers.each do |s|
      states << s.address.state.upcase if s.address and s.address.country == "US" and Word.is_in_family?(s.address.state,"us_states",:shortform)
    end
    return states.uniq.sort
  end

end
