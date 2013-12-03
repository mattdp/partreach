# == Schema Information
#
# Table name: geographies
#
#  id            :integer          not null, primary key
#  level         :string(255)
#  short_name    :string(255)
#  long_name     :string(255)
#  name_for_link :string(255)
#  geography_id  :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Geography < ActiveRecord::Base

	#ideally, validate short_name unique within a level, but not important until internationalize
	validates :level, presence: true
	validates :name_for_link, presence: true, uniqueness: {case_sensitive: false}

	#has a parent geography containing it, or nil if top level
	belongs_to :geography

	#since the syntax of a self-referential parent is confusing
	def get_containing_geography
		return self.geography
	end

	def self.create_or_reference_geography(text,symbol,level)
		geo = Geography.locate(text,symbol,level)
		return geo if geo
		create_hash = {level: level}
		create_hash[symbol] = text
		geo = Geography.new(create_hash) 
		geo.save(validate: false)
		return geo
	end	

  def self.locate(text,symbol,level)
  	Geography.all.detect {|geo| geo.send(symbol) == text and geo.level == level}
  end

	def self.proper_name_for_link(input)
		return Supplier.proper_name_for_link(input)
	end

  def self.transform(from_symbol,input,to_symbol,level=nil)
    geo = Geography.locate(input,from_symbol,level)
    return nil if geo.nil?
    return geo.send(to_symbol)
  end

  def self.all_us_states_short_name
  	if us = Geography.locate("United States",:long_name,"country")
  		Geography.where("level = 'state' and geography_id = ?",us.id).map{|g| g.short_name}
  	else
  		return nil
  	end
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
