class Filter
	attr_reader :name, :limits, :up_front_states, :tags_name, :tags_short, :tags_long

	def self.all
		all = {}
		Filter.raw_list.each do |line|
			all[line[0]] = new(line[0],line[1],line[2],line[3])
		end
		return all
	end

	def initialize(name,limits,up_front_states,tag_short_and_long)
		@name = name
		@up_front_states = up_front_states
		if tag_short_and_long.present?
			@tags_short = tag_short_and_long[0]
			@tags_long = tag_short_and_long[1]
		end

		@limits = {}
		counter = 0
		limit_keys = [:and_style_haves, :or_style_haves, :and_style_have_nots, :countries, :states]
		limit_keys.each do |key|
			@limits[key] = limits[counter]
			counter += 1
		end
	end

	def self.get(name)
		all = Rails.cache.fetch "filter_all", :expires_in => 25.hours do |key|
			Filter.all
		end 
		return all[name]
	end

  #index is {name => [[mandatory have tags 'ands'],[have one of to get into set 'ors'][ mandatory have nots tags],[countries]]}
  # => needs to have at least one thing in one of the first two categories

	def self.raw_list
		[
			[	"us_3d_printing",
				[
					[],
					["3d_printing"],
					["datadump"],
					["US"],
					[]
				],
				["no_state","CA","NY"],
				nil
			],
			[ "us_sls",
				[
					["SLS"],
					[],
					["datadump"],
					["US"],
					[]
				],
				["no_state","CA"],
				nil
			],
			[ "us_sla",
				[
					["SLA"],
					[],
					["datadump"],
					["US"],
					[]
				],
				["no_state","CA"],
				nil
			],
			[ "us_custom_machining",
				[
					["custom_machining"],
					[],
					["datadump"],
					["US"],
					[]
				],
				["no_state","CA"],
				nil
			],
			[ "us_fdm-and-fff",
				[
					[],
					["FDM","FFF"],
					["datadump"],
					["US"],
					[]
				],
				["no_state","CA"],
				["FDM and FFF","The proprietary and nonproprietary names for a printing process that constructs a 3D model by laying down a bead of heated plastic one layer at a time."]
			]							
		]
	end

end