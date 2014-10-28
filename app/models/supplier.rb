# == Schema Information
#
# Table name: suppliers
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  url_main                      :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  description                   :text
#  url_materials                 :string(255)
#  source                        :string(255)      default("manual")
#  profile_visible               :boolean          default(FALSE)
#  name_for_link                 :string(255)
#  claimed                       :boolean          default(FALSE)
#  suggested_description         :text
#  suggested_machines            :text
#  suggested_preferences         :text
#  internally_hidden_preferences :text
#  suggested_services            :text
#  suggested_address             :text
#  suggested_url_main            :string(255)
#  points                        :integer          default(0)
#  next_contact_date             :date
#  next_contact_content          :string(255)
#

class Supplier < ActiveRecord::Base
  belongs_to :user

  before_create :append_http_to_url

  has_many :dialogues, :dependent => :destroy
  has_one :address, :as => :place, :dependent => :destroy
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :owners, :dependent => :destroy
  has_many :machines, :through => :owners
  has_many :externals, :as => :consumer, :dependent => :destroy
  has_many :reviews, :dependent => :destroy
  has_many :communications, as: :communicator, :dependent => :destroy
  has_one :web_search_result, :dependent => :destroy

  has_one :contract_contact, :as => :contactable, :dependent => :destroy
  has_one :billing_contact, :as => :contactable, :dependent => :destroy
  has_one :rfq_contact, :as => :contactable, :dependent => :destroy

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :name_for_link, presence: true, uniqueness: {case_sensitive: false}
  validates :url_main, uniqueness: {case_sensitive: false}, allow_nil: true
  validates :points, numericality: true
  validates_presence_of :address
  validates_presence_of :contract_contact
  validates_presence_of :billing_contact
  validates_presence_of :rfq_contact

  DEFAULT_BID_FEE = 0.01 # 1%

  #unreadable without the method that assesses suppliers. After this is more fixed, make it into a model.
  def self.get_point_structure
    preloader = 
    [
      [
        "has_description",
        "Description",
        20,
        1,
        true,
        "Profile has an approved description of the supplier.",
        "self.description.present? ? values[:points] : 0"
      ],
      [
        "has_machines",
        "Machines",
        20,
        1,
        true,
        "Profile has at least one machine listed.",
        "self.machines.count > 0 ? values[:points] : 0"
      ],
      [
        "has_reviews",
        "Reviews",
        20,
        4,
        true,
        "Profile has up to four approved reviews.",
        "[self.visible_reviews.count * values[:points], values[:repeats] * values[:points]].min"
      ],
      [
        "profile_claimed",
        "Profile claimed",
        40,
        1,
        true,
        "Supplier has claimed profile.",
        "self.claimed ? values[:points] : 0"
      ]
      # [
      #   "not_in_use",
      #   100,
      #   4,
      #   false,
      #   "Shouldn't show up",
      #   "100"
      # ]
    ]
    structure = {}
    preloader.map{ |key,shortform,points,repeats,in_use,longform,assessment| 
                    structure[key] = {
                      points: points, #how many points for fulfilling criteria once
                      shortform: shortform, #small description for table
                      repeats: repeats, #how many times can you fulfill criteria for score
                      in_use: in_use, #is this currently used on the site
                      longform: longform, #longer description than key
                      assessment: assessment #code to see how many points a supplier gets
                    }
                  }
    return structure
  end

  def self.suppliers_for_new_dialogue
    suppliers = Supplier.includes(:tags).references(:tags).includes([{ address: :country }, { address: :state }]).order("lower(suppliers.name)")
  end

  def self.all_signed
    signed = []
    Tag.tag_set(:network,:id).each do |tag_id|
      signed = signed.concat(Supplier.quantity_by_tag_id("all",tag_id))
    end
    return signed
  end

  def self.all_claimed
    Supplier.where("claimed = true")
  end

  #suppliers that have made updates to their own profiles
  def self.all_claimed_and_updated
    potentials = Supplier.all_claimed
    updatable_fields = [:suggested_description, :suggested_machines, :suggested_preferences, \
                        :suggested_services, :suggested_address, :suggested_url_main]
    updated = []
    potentials.each do |supplier|
      updated << supplier if updatable_fields.any?{|field| supplier.send(field).present?}
    end
    return updated
  end

  def self.get_in_use_point_structure
    return Supplier.get_point_structure.delete_if{ |key,values| !values[:in_use] }
  end

  #doesn't check if in use, does check if supplier in network
  def point_scoring(structure)
    return structure.map { |key, values| eval(values[:assessment]) }.sum
  end

  #doesn't check if in use
  def self.max_point_scoring(structure)
    return structure.map { |key, values| values[:repeats] * values[:points] }.sum
  end

#TODO - re-write method
#assumes tags are only on suppliers, so will return incorrect result when tags on other types are added
  def self.pending_examination
    return Tagging.joins(:tag).references(:tag).where("name='datadump'").count
  end

  def self.create_new_from_supplier_search_result_examination(params)
    new_supplier = Supplier.new(params)
    new_supplier.name_for_link = proper_name_for_link(new_supplier.name)
    new_supplier.create_or_update_address
    new_supplier.billing_contact = BillingContact.new
    new_supplier.contract_contact = ContractContact.new
    new_supplier.rfq_contact = RfqContact.new
    new_supplier.source = 'supplier_search_result_examination'
    new_supplier.profile_visible = false
    new_supplier.save
    Tag.tag_set(:new_supplier,:id).each do |id|
      new_supplier.add_tag(id)
    end
    new_supplier.add_tag(Tag.find_by_name("datadump").id)
    new_supplier
  end

  def update_tags(submitted_tag_ids)
    saved_ok = true
    
    if(submitted_tag_ids and submitted_tag_ids.size > 0)

      current_tag_ids = self.tags.map{|t| "#{t.id}"}
      add_tag_ids = []
      remove_tag_ids = []

      submitted_tag_ids.map{|t| add_tag_ids << t if !t.in?(current_tag_ids)}
      current_tag_ids.map{|t| remove_tag_ids << t if !t.in?(submitted_tag_ids)}

      if add_tag_ids.size > 0
        add_tag_ids.each do |id|
          saved_ok = false unless self.add_tag(id)
        end
      end

      if remove_tag_ids.size > 0
        remove_tag_ids.each do |id|
          saved_ok = false unless self.remove_tags(id)
        end
      end
    end

    return saved_ok
  end

  def asks_hash
    answer = {}
    self_id = self.id
    Ask.find_each do |a|
      if a.real and a.supplier_id == self_id
        if answer[a.request].present?
          answer[a.request] += 1 
        else
          answer[a.request] = 1
        end
      end
    end
    return answer
  end

  #return hash of [machine => quantity]
  def machines_quantity_hash
    answer = {}
    owners = self.owners
    owners.each do |o|
      m = o.machine_id
      if answer[m].nil?
        answer[m] = 1
      else
        answer[m] += 1
      end
    end
    return answer
  end

  def is_in_network?
    network_tag_ids = Tag.tag_set(:network,:id)
    network_tag_ids.each do |tag_id|
      return true if self.has_tag?(tag_id)
    end
    return false
  end

  def existence_questionable?
    risky_tag_ids = Tag.tag_set(:risky,:id)
    risky_tag_ids.each do |tag_id|
      return true if self.has_tag?(tag_id)
    end
    return false    
  end

  def claim_profile(user_id)
    attach_to_user(user_id)
    self.claimed = true
    Event.add_event("Supplier",self.id,"claimed_profile") if self.save
  end

  def attach_to_user(user_id)
    user = User.find(user_id)
    user.supplier_id = self.id
    return user.save(:validate => false)
  end

  def self.proper_name_for_link(name)
    return name.downcase.gsub(/\W+/, "")
  end

  def from_notes(field, options = {})
    return false if self.address.nil? or self.address.country.short_name != "US" or self.address.notes.nil?
    if field == "zip"
      return false if self.address.zip and self.address.zip.length > 0
      matched = self.address.notes.match(/.*(\d{5})/)
      return false if matched.nil?
      puts "\n#{self.address.notes} ::::: #{matched[1]}" if options[:debug]
      return matched[1]
    elsif field == "state"
      return false if self.address.state.short_name and self.address.state.short_name.length > 0
      matched = self.address.notes.match(/.* ([A-Z]{2}) /)
      return false if matched.nil?
      puts "\n#{self.address.notes} ::::: #{matched[1]}" if options[:debug]           
      return matched[1]
    end
  end

#minimal modification of method to use Tagging vs. Combo
#TODO - re-write!!!
#assumes tags are only on suppliers, so will break when tags on other types are added
#also, very inefficient
  def self.quantity_by_tag_id(quantity,tag_id,country=nil,state=nil)
    quantity = Tagging.all.count if quantity == "all"
    combos = Tagging.where("tag_id = ?", tag_id).take(quantity)
    return [] if combos == []
    suppliers = Supplier.find(combos.map{|c| c.taggable_id})
    suppliers = suppliers.delete_if{|s| s.address.country.short_name != country} if country
    return [] if suppliers == []
    suppliers = suppliers.delete_if{|s| s.address.state.short_name != state} if state    
    return suppliers
  end

  # return suppliers missing state, zip, email, or phone
  def self.missing_contact_information(max_quantity)

    potential_return = RfqContact.where("email IS NULL OR email = ''")
    return potential_return.take(max_quantity).map{|contact| contact.contactable} if potential_return.present?

    potential_return = RfqContact.where("phone IS NULL OR phone = ''")
    return potential_return.take(max_quantity).map{|contact| contact.contactable} if potential_return.present?

    geo = Geography.where("level = 'countryy' AND short_name = ''")[0]
    potential_return = Address.where("country_id = ? AND place_type = 'Supplier'",geo.id)
    return potential_return.take(max_quantity).map{|address| address.place} if potential_return.present?

    geo = Geography.where("level = 'statee' AND short_name = ''")[0]
    potential_return = Address.where("state_id = ? AND place_type = 'Supplier'", geo.id)
    return potential_return.take(max_quantity).map{|address| address.place} if potential_return.present?

    potential_return = Address.where("zip IS NULL OR zip = ''")
    return potential_return.take(max_quantity).map{|address| address.place} if potential_return.present?

    return []
  end

  def add_communication(interaction_title,means_of_interaction="email")
    c = Communication.new({ communicator_id: self.id,
                            communicator_type: "Supplier",
                            means_of_interaction: means_of_interaction,
                            interaction_title: interaction_title
                          })
    return c.save
  end

  def add_tag(tag_id)
    tag = Tag.find_by_id(tag_id)
    return false if self.tags.include?(tag)
    if tag.tag_group.exclusive
      self.tags.each do |t|
        self.tags.destroy(t) if t.tag_group_id == tag.tag_group_id
      end
    end
    self.tags << tag
    Event.add_event("Supplier",self.id,"joined_network")if Tag.tag_set(:network,:name).include?(tag.name)
    return true
  end

  def remove_tags(tag_id)
    self.tags.destroy(tag_id)
  end

  def has_tag?(tag_id)
    t = Tag.find_by_id(tag_id)
    return false if t.nil?    
    if self.tags.include?(t)
      return true
    else
      return false
    end
  end

  def add_machine(machine_id, quantity=1)
    m = Machine.find_by_id(machine_id)  
    return false if m.nil?
    w = false
    (1..quantity).each do |n|
      w = Owner.create(supplier_id: self.id, machine_id: machine_id) 
    end
    return w
  end

  def remove_machines(machine_id)
    w = Owner.where("supplier_id = ? AND machine_id = ?", self.id, machine_id)
    Owner.destroy_all(supplier_id: self.id, machine_id: machine_id) unless w.nil?
  end

  def has_machine?(machine_id)
    m = Machine.find_by_id(machine_id)
    return false if m.nil?
    if self.machines.include?(m)
      return(true)
    else
      return(false)
    end
  end 

  def add_external(url)
    e = External.new(consumer_id: self.id, consumer_type: "Supplier", url: url)
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

  def internal_tags
    return nil if self.tags.nil?
    answer = []
    self.tags.each do |t|
      answer << t if !t.visible
    end
    return answer
  end  

  def self.visible_profiles
    Supplier.where('profile_visible = true')
  end

  def visible_reviews
    Review.where('supplier_id = ? and displayable = true', self.id)
  end

  #this will be slow, need to store it somewhere
  def self.visible_set_for_index(filter)
    return false if filter.nil?
    holder = []
    Supplier.find_each do |supplier|
      if Supplier.index_validation(supplier, filter)
        holder << supplier
      end
    end
    return holder
  end

  def self.index_validation(supplier, filter)
    return false unless supplier.tags.present?
    test_visibility = supplier.profile_visible
    geo = filter.geography
    test_geography = (supplier.address.attributes["#{geo.level}_id"] == geo.id)
    test_has_tag = supplier.has_tag?(filter.has_tag.id)
    test_has_not_tag = !supplier.has_tag?(filter.has_not_tag.id)

    return (test_visibility and test_geography and test_has_tag and test_has_not_tag)
  end

  def array_for_sorting
    out_of_business = Tag.tag_set(:risky,:id).any?{ |t_id| self.has_tag?(t_id) }
    country_link = address.country.name_for_link
    state_link = address.state.name_for_link
    return [self, owners.count, reviews.count, claimed, out_of_business, country_link, state_link]
  end

  #return nested, ordered arrays of [country][state][supplier,machine_count,review_count,claimed,out_of_business,country_link,state_link]
  #super slow, relies on caching
  #unknown for country -> supplier direct stuff

  def self.visible_profiles_sorted(filter)

    profiles = Supplier.visible_set_for_index(filter)
    count = 0
    order = ActiveSupport::OrderedHash.new
    chaos = {}

    if !(profiles.nil? or profiles == [] or profiles == false)
      countable = profiles.find_all {|supplier| !supplier.existence_questionable?}
      count = countable.count
      profiles.each do |s|  
        country = s.address.country.short_name
        state = s.address.state.short_name
        array_for_sorting = s.array_for_sorting
        chaos[country] = {} if chaos[country].nil?
        if chaos[country][state].nil?
          chaos[country][state] = [array_for_sorting]
        else
          chaos[country][state] << array_for_sorting
        end
      end

      chaos.keys.sort.each do |country|
        order[country] = ActiveSupport::OrderedHash.new
        ufs = ["unknown","CA","NY"]
        if ufs.present? 
          ufs.each do |upfront| #http://stackoverflow.com/questions/73032/how-can-i-sort-by-multiple-conditions-with-different-orders
            order[country][upfront] = chaos[country][upfront].sort{ |a,b| [b[0].points, a[0].name.downcase] <=> [a[0].points, b[0].name.downcase] } if chaos[country][upfront].present?
          end
        end
        chaos[country].keys.sort.each do |state|
          order[country][state] = chaos[country][state].sort{ |a,b| [b[0].points, a[0].name.downcase] <=> [a[0].points, b[0].name.downcase] } unless (ufs.present? and state.in?(ufs))
        end
      end

    end

    return [order, count]

  end

  def create_or_update_address(options={})
    Address.create_or_update_address(self,options)
  end

  def safe_country
    return self.address.country.short_name if self.address.country.short_name.present?
    return "no-country"
  end

  def safe_state
    return self.address.state.short_name if self.address.state.short_name.present?
    return ""
  end 

  def safe_zip
    return self.address.zip if self.address.zip.present?
    return ""
  end  

  def safe_location_name
    if self.address.country.short_name == "US"
      l = Location.find_by_zip(self.address.zip) if self.address.zip.present?
      return l.location_name if !l.nil?
    end
    return ""
  end   

  def get_supporting_info
    datadump_id = Tag.find_by_name("datadump").id
    if self.address.nil? or self.address.country.short_name != "US" or self.address.state.short_name.nil?
      return self.supplier_names_by_first_character
    else
      suppliers = Address.find_supplier_ids_by_country_and_state(self.address.country,self.address.state)
      screened_suppliers = suppliers.reject{|s| s.has_tag?(datadump_id)}
      return "No others in that country/state." if !screened_suppliers.present?
      return "Other non-datadump suppliers in that state: #{screened_suppliers.map{|s| s.name}.sort}"
    end
  end

  def supplier_names_by_first_character
    datadump_id = Tag.find_by_name("datadump").id
    char = self.name[0].downcase
    suppliers = Supplier.where("LOWER(LEFT(name,1)) = ?", char)
    screened_suppliers = suppliers.reject{|s| s.has_tag?(datadump_id)}
    return "Other non-datadump suppliers with names starting with #{char.upcase}: #{screened_suppliers.map{|s| s.name}.sort}"
  end

  def append_http_to_url
    if self.url_main
      self.url_main = /^http/.match(self.url_main) ? self.url_main : "http://#{self.url_main}"
    end
  end

  def self.next_contact_suppliers_sorted(only_after_today=true)
    if only_after_today
      where_clause = "next_contact_date IS NOT NULL AND next_contact_date <= '#{Date.today.to_s}'"
    else
      where_clause = "next_contact_date IS NOT NULL"
    end

    return Supplier.where(where_clause).order("next_contact_date ASC")
  end

  def self.with_machine(machine_id)
    owners = Owner.where("machine_id = ?",machine_id)
    if owners.present?
      ids = owners.map{|o| o.supplier_id}
      @suppliers = ids.uniq.map{|id| Supplier.find(id)}
    else
      @suppliers = nil
    end
  end

end
