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
#  country_id :integer
#  state_id   :integer
#

class Address < ActiveRecord::Base

  belongs_to :place, :polymorphic => true
  belongs_to :country, class_name: 'Geography'
  belongs_to :state, class_name: 'Geography'

  validates :place_id, presence: true
  validates :place_type, presence: true

  def readable
    return "#{self.street} #{self.city} #{self.state} #{self.zip} #{self.country}"
  end

  def self.find_supplier_ids_by_country_and_state(country,state)
    addresses = Address.where("country = ? and state = ? and place_type = ?", \
      country, state, "Supplier")
    return [] if addresses == []
    suppliers = Supplier.find(addresses.map{|a| a.place_id})
  end

  def self.us_states_of_visible_profiles
    states = []
    suppliers = Supplier.visible_profiles
    suppliers.each do |s|
      states << s.address.state.short_name.upcase if s.address.state.level == "state" and s.address.state.short_name and s.address.country.short_name == "US"
    end
    return states.uniq.sort
  end

end
