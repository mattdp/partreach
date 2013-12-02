class Filter
	attr_reader :name, :limits, :up_front_states, :tags_short, :tags_long

	def self.all
		all = {}

		Filter.raw_list.each do |line|
			all[line[0]] = new(line[0],line[1],line[2],line[3])
		end

		us_states = Geography.all_us_states_short_name
		tags_and_custom_for_each_state = [
			[["SLS"],[]],
			[["3d_printing"],[]],
			[["SLA"],[]],
			[["FDM","FFF"],["FDM and FFF","The proprietary and nonproprietary names for a printing process that constructs a 3D model by laying down a bead of heated plastic one layer at a time."]]
		]
		tags_and_custom_for_each_state.each do |line|
			line[0] = line[0].map{|name| Tag.find_by_name(name)}
		end

		us_states.each do |state|
			tags_and_custom_for_each_state.each do |tags,custom_descriptions|
				tag_combination_name = Filter.name_formatter("US",state,tags.map{|tag| tag.name_for_link}.join("-"))
				all[tag_combination_name] = new(
					tag_combination_name,
					[
						[],
						tags.map{|tag| tag.name},
						["datadump"],
						["US"],
						[state]
					],
					nil, #no prioritized state, since in a state
					custom_descriptions.present? ? custom_descriptions : nil
				)
			end
		end

		return all
	end

	def self.name_formatter(country,state,tag_combination_name)
		return "#{country}-#{state}-#{tag_combination_name}"
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