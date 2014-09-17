# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  street     :string(255)
#  city       :string(255)
#  zip        :string(255)
#  created_at :datetime
#  updated_at :datetime
#  place_id   :integer
#  place_type :string(255)
#  notes      :text
#  country_id :integer
#  state_id   :integer
#

class Address < ActiveRecord::Base

  belongs_to :place, polymorphic: true
  belongs_to :country, class_name: 'Geography'
  belongs_to :state, class_name: 'Geography'

  #validates :place_id, presence: true
  #validates :place_type, presence: true
  #should point to something, even if that something is a blank
  validates_presence_of :country
  validates_presence_of :state

  def readable
    return "#{self.street} #{self.city} #{self.state.long_name} #{self.zip} #{self.country.long_name}"
  end

  #inefficient, but only used in reviews
  def self.find_supplier_ids_by_country_and_state(country,state)
    addresses = []
    Address.find_each do |a|
      addresses << a if a.state.id == state.id and a.country.id == country.id
    end
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

  #allows, from console, quick geo consolidation
  def self.geo_merge_and_destroy(destroyed_id,remaining_id)
    Address.find_each do |a|
      a.country_id = remaining_id if a.country_id == destroyed_id
      a.state_id = remaining_id if a.state_id == destroyed_id
      a.save
    end
    Geography.find(destroyed_id).destroy
  end

  #country, state, zip only right now
  def self.create_or_update_address(owner, options)
    if owner.address
      address = owner.address
    else
      address = Address.new({place_id: owner.id, place_type: owner.class.to_s})
    end

    if options[:country]
      address.country = Geography.find_or_create_country(options[:country])
    elsif address.country.nil?
      # TODO refactor - it would probably be simpler to just use nil to represent country/state not known,
      # but first need to refactor code that assumes that these fields are never nil
      address.country = Geography.find_by_name_for_link('country_unknown')
    end

    if options[:state]
      address.state = Geography.find_or_create_state(options[:state])
    elsif address.state.nil?
      address.state = Geography.find_by_name_for_link('state_unknown')
    end

    address.zip = options[:zip] if options[:zip]

    address.save
    owner.address(true) # force refresh of address association for in-memory owner object
  end

end
