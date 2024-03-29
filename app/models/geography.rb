# == Schema Information
#
# Table name: geographies
#
#  id            :integer          not null, primary key
#  level         :string(255)
#  short_name    :string(255)
#  long_name     :string(255)
#  name_for_link :string(255)      not null
#  geography_id  :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Geography < ActiveRecord::Base

  #ideally, validate short_name unique within a level, but not important until internationalize
  validates :level, presence: true
  validates :name_for_link, presence: true

  #has a parent geography containing it, or nil if top level
  belongs_to :geography
  #don't think this works right now
  has_many :addresses

  #since the syntax of a self-referential parent is confusing
  def get_containing_geography
    return self.geography
  end

  #input {living_geo_id_A: [replaces_id_1, replaces_id_2], living_geo_id_B: ...}
  #goal: one pass through addresses
  def self.absorb(geographies)
    
    #make it easier to work with
    machine_friendly = {}
    geographies.each do |winner,absorbed|
      absorbed.each do |loser_id|
        machine_friendly[loser_id] = winner
      end
    end

    keys = machine_friendly.keys
    Address.find_each do |address|
      changed = false
      [:country_id,:state_id].each do |attribute|
        old_geo = address.send(attribute)
        if keys.include?(old_geo)
          new_geo = machine_friendly[old_geo]
          address.send("#{attribute}=",new_geo)
          puts "Address #{address.id} #{attribute} changed from #{old_geo} to #{new_geo}"
          changed = true
        end
      end
      address.save if changed
    end

    chopping_block = Geography.find(machine_friendly.keys)
    chopping_block.each do |geo|
      puts "Destroying Geography #{geo.id}: #{geo.short_name} #{geo.long_name}"      
      geo.destroy
    end

  end

  def self.find_or_create_country(name)
    self.find_or_create(name, 'country')
  end

  def self.find_or_create_state(name)
    self.find_or_create(name, 'state')
  end

  def self.find_or_create(name, level)
    # make match case-insensitive?
    geo = ( Geography.locate(name, :short_name, level) ||
            Geography.locate(name, :long_name, level) )

    unless geo
      name_for_link = self.proper_name_for_link("#{level}_#{name}")
      geo = Geography.create!(
        level: level, short_name: name, long_name: name, name_for_link: name_for_link)
    end

    geo
  end

  def self.output_readable_table
    Geography.find_each do |g|
      puts "#{g.id}: #{g.short_name} (#{g.long_name})"
    end
  end

  def self.locate(text,symbol,level)
    Geography.where(symbol => text, :level => level).first
  end

  def self.proper_name_for_link(input)
    return Supplier.proper_name_for_link(input)
  end

  def self.transform(from_symbol,input,to_symbol,level=nil)
    geo = Geography.locate(input,from_symbol,level)
    return nil if geo.nil?
    return geo.send(to_symbol)
  end

  def self.all_us_states
    Geography.where(level: 'state').where(geography_id: Geography.select(:id).where(short_name: 'US'))
  end

  def self.all_countries
    return Geography.where(level: 'country')
  end

  def self.loader(array, parent=nil)
    array.each do |a|
      g = Geography.new({short_name: a[0], long_name: a[1], level: a[2], \
        name_for_link: Geography.proper_name_for_link(a[1])})
      g.geography_id = parent if parent
      puts "Error saving ['#{a[0]}', '#{a[1]}']" unless g.save
    end
    return true
  end

  def self.initial_information

    countries = 
      [
        ["US","United States","country"]
      ]
      
    us_states =
      [ 
        ["AL","Alabama","state"],
        ["AK","Alaska","state"],
        ["AZ","Arizona","state"],
        ["AR","Arkansas","state"],
        ["CA","California","state"],
        ["CO","Colorado","state"],
        ["CT","Connecticut","state"],
        ["DE","Delaware","state"],
        ["DC","District of Columbia","state"],
        ["FL","Florida","state"],
        ["GA","Georgia","state"],
        ["HI","Hawaii","state"],
        ["ID","Idaho","state"],
        ["IL","Illinois","state"],
        ["IN","Indiana","state"],
        ["IA","Iowa","state"],
        ["KS","Kansas","state"],
        ["KY","Kentucky","state"],
        ["LA","Louisiana","state"],
        ["ME","Maine","state"],
        ["MD","Maryland","state"],
        ["MA","Massachusetts","state"],
        ["MI","Michigan","state"],
        ["MN","Minnesota","state"],
        ["MS","Mississippi","state"],
        ["MO","Missouri","state"],
        ["MT","Montana","state"],
        ["NE","Nebraska","state"],
        ["NV","Nevada","state"],
        ["NH","New Hampshire","state"],
        ["NJ","New Jersey","state"],
        ["NM","New Mexico","state"],
        ["NY","New York","state"],
        ["NC","North Carolina","state"],
        ["ND","North Dakota","state"],
        ["OH","Ohio","state"],
        ["OK","Oklahoma","state"],
        ["OR","Oregon","state"],
        ["PA","Pennsylvania","state"],
        ["RI","Rhode Island","state"],
        ["SC","South Carolina","state"],
        ["SD","South Dakota","state"],
        ["TN","Tennessee","state"],
        ["TX","Texas","state"],
        ["UT","Utah","state"],
        ["VT","Vermont","state"],
        ["VA","Virginia","state"],
        ["WA","Washington","state"],
        ["WV","West Virginia","state"],
        ["WI","Wisconsin","state"],
        ["WY","Wyoming","state"]
      ]

    Geography.loader(countries)
    parent_id = Geography.locate("United States",:long_name,"country").id
    Geography.loader(us_states,parent_id) if parent_id
  
  end

end
