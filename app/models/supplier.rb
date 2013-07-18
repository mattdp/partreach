# == Schema Information
#
# Table name: suppliers
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  url_main        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  description     :text
#  email           :string(255)
#  phone           :string(255)
#  url_materials   :string(255)
#  source          :string(255)      default("manual")
#  profile_visible :boolean          default(FALSE)
#  name_for_link   :string(255)
#  claimed         :boolean          default(FALSE)
#

class Supplier < ActiveRecord::Base
  attr_accessible :name, :name_for_link, :url_main, :url_materials, :description, :email, :phone, :address_id, :source, :profile_visible, :claimed

  has_many :dialogues
  has_one :address, :as => :place, :dependent => :destroy
  has_many :combos, :dependent => :destroy
  has_many :tags, :through => :combos
  has_many :owners, :dependent => :destroy
  has_many :machines, :through => :owners
  has_many :externals, :dependent => :destroy

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  def self.proper_name_for_link(name)
    return name.downcase.gsub(/\W+/, "")
  end

  def from_notes(field, options = {})
    return false if self.address.nil? or self.address.country != "US" or self.address.notes.nil?
    if field == "zip"
      return false if self.address.zip and self.address.zip.length > 0
      matched = self.address.notes.match(/.*(\d{5})/)
      return false if matched.nil?
      puts "\n#{self.address.notes} ::::: #{matched[1]}" if options[:debug]
      return matched[1]
    elsif field == "state"
      return false if self.address.state and self.address.state.length > 0
      matched = self.address.notes.match(/.* ([A-Z]{2}) /)
      return false if matched.nil?
      puts "\n#{self.address.notes} ::::: #{matched[1]}" if options[:debug]           
      return matched[1]
    end
  end

  def self.quantity_by_tag_id(quantity,tag_id)
    combos = Combo.where("tag_id = ?", tag_id).take(quantity)
    return [] if combos == []
    return Supplier.find(combos.map{|c| c.supplier_id})
  end

  def add_tag(tag_id)
    t = Tag.find_by_id(tag_id)    
    return false if t.nil?    
    match = Combo.where("supplier_id = ? AND tag_id = ?", self.id, tag_id)
    return false unless match == [] 
    c = Combo.new(supplier_id: self.id, tag_id: tag_id)
    Combo.destroy_family_tags(self.id,tag_id) if t.exclusive and !t.family.nil?
    return c.save
  end

  def remove_tag(tag_id)
    c = Combo.where("supplier_id = ? AND tag_id = ?", self.id, tag_id)
    Combo.destroy_all(supplier_id: self.id, tag_id: tag_id) unless c.nil? or c == []
  end

  def has_tag?(tag_id)
    t = Tag.find_by_id(tag_id)
    return false if t.nil?    
    self.tags.include?(t)
  end

  def add_machine(machine_id)
    m = Machine.find_by_id(machine_id)    
    return false if m.nil?
    w = Owner.new(supplier_id: self.id, machine_id: machine_id) 
    return w.save
  end

  def remove_machine(machine_id)
    w = Owner.where("supplier_id = ? AND machine_id = ?", self.id, machine_id)
    Owner.destroy_all(supplier_id: self.id, machine_id: machine_id) unless w.nil?
  end

  def has_machine?(machine_id)
    m = Machine.find_by_id(machine_id)
    return false if m.nil?
    self.machines.include?(m)
  end 

  def add_external(url)
    e = External.new(supplier_id: self.id, url: url)
    e.save
  end

  def visible_tags
    return nil if self.tags.nil?
    answer = []
    self.tags.each do |t|
      answer << t if t.visible
    end
    return answer
  end

  def self.visible_profiles
    Supplier.where('profile_visible = true')
  end

  #return hash of countries, each with hash of states, containing array of suppliers
  #no_state for country -> supplier direct stuff
  def self.visible_profiles_sorted
    profiles = Supplier.visible_profiles

    answer = {}

    profiles.each do |s|  
      next if s.address.nil? or s.address.country.nil?
      country = s.address.country
      state = s.address.state
      answer[country] = {"no_state" => []} if answer[country].nil?
      if s.address.state.nil?
        answer[country]["no_state"] << s
        answer[country]["no_state"].sort! { |a,b| a.name <=> b.name }
      elsif answer[country][state].nil?
        answer[country][state] = [s]
      else
        answer[country][state] << s
        answer[country][state].sort! { |a,b| a.name <=> b.name }
      end
    end

    return answer
  end

  def create_or_update_address(options)
    return false if options.nil? or options == {}
    address_attributes = options.delete_if { |k,v| v.nil? or v.empty?}

    if self.address
      self.address.update_attributes(address_attributes)
    else
      self.address = Address.create(address_attributes)
    end

  end

  def safe_country
    return self.address.country if self.address and self.address.country.present?
    return "no-country"
  end

  def safe_state
    return self.address.state if self.address and self.address.state.present?
    return ""
  end 

  def safe_zip
    return self.address.zip if self.address and self.address.zip.present?
    return ""
  end  

  def safe_location_name
    if self.address and self.address.country and self.address.country = "US"
      l = Location.find_by_zip(self.address.zip) if self.address.zip.present?
      return l.location_name if !l.nil?
    end
    return ""
  end   

  def get_supporting_info
    return "Need more geo information for comparison!" if \
    self.address.nil? or self.address.country != "US" or self.address.state.nil?
    suppliers = Address.find_supplier_ids_by_country_and_state(self.address.country,self.address.state)
    screened_suppliers = suppliers.reject{|s| s.has_tag?(Tag.find_by_name("datadump").id)}
    return "No others in that country/state." if !screened_suppliers.present?
    return "Other suppliers in that state: #{screened_suppliers.map{|s| s.name}.sort}"
  end

end

#may need to add material and method
