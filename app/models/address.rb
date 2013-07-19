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

  def self.is_us_state?(text,longform = false)
    return false if text.nil?
    compare_to = longform ? :keys : :values
    US_STATE_HASH.send(compare_to).map{|k| k.downcase}.include?(text.downcase)
  end

  def self.abbreviate_us_state(longform)
    return US_STATE_HASH[longform]
  end

  US_STATE_HASH = 
    {"Alabama" => "AL",
    "Alaska" => "AK",
    "Arizona" => "AZ",
    "Arkansas" => "AR",
    "California" => "CA",
    "Colorado" => "CO",
    "Connecticut" => "CT",
    "Delaware" => "DE",
    "District of Columbia" => "DC",
    "Florida" => "FL",
    "Georgia" => "GA",
    "Hawaii" => "HI",
    "Idaho" => "ID",
    "Illinois" => "IL",
    "Indiana" => "IN",
    "Iowa" => "IA",
    "Kansas" => "KS",
    "Kentucky" => "KY",
    "Louisiana" => "LA",
    "Maine" => "ME",
    "Maryland" => "MD",
    "Massachusetts" => "MA",
    "Michigan" => "MI",
    "Minnesota" => "MN",
    "Mississippi" => "MS",
    "Missouri" => "MO",
    "Montana" => "MT",
    "Nebraska" => "NE",
    "Nevada" => "NV",
    "New Hampshire" => "NH",
    "New Jersey" => "NJ",
    "New Mexico" => "NM",
    "New York" => "NY",
    "North Carolina" => "NC",
    "North Dakota" => "ND",
    "Ohio" => "OH",
    "Oklahoma" => "OK",
    "Oregon" => "OR",
    "Pennsylvania" => "PA",
    "Rhode Island" => "RI",
    "South Carolina" => "SC",
    "South Dakota" => "SD",
    "Tennessee" => "TN",
    "Texas" => "TX",
    "Utah" => "UT",
    "Vermont" => "VT",
    "Virginia" => "VA",
    "Washington" => "WA",
    "West Virginia" => "WV",
    "Wisconsin" => "WI",
    "Wyoming" => "WY"
  }

end
