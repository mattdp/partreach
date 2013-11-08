class Filter
	attr_reader :name, :format, :limits, :up_front_states, :tags_name, :tags_short, :tags_long

	def self.all
		all = {}
		Filter.raw_list.each do |line|
			all[line[0]] = new(line[0],line[1],line[2],line[3],line[4])
		end
		return all
	end

	def initialize(name,format,limits,up_front_states,tag_short_and_long)
		@name = name
		@format = format
		@up_front_states = up_front_states
		if tag_short_and_long.present?
			@tags_short = tag_short_and_long[0]
			@tags_long = tag_short_and_long[1]
		end

		@limits = {}
		if format == "cst"
			a,b,c = :country,:state,:tag_name
			@limits[a], @limits[b], @limits[c] = limits[0], limits[1], limits[2]
		elsif format == "stipulations"
			a,b = :and_style_haves, :or_style_haves
			c,d = :and_style_have_nots, :countries
			@limits[a], @limits[b], @limits[c], @limits[d] = limits[0], limits[1], limits[2], limits[3]
		end
	end

	def self.get(name)
		return Filter.all[name]
	end

  #index is {name => [[mandatory have tags 'ands'],[have one of to get into set 'ors'][ mandatory have nots tags],[countries]]}
  # => needs to have at least one thing in one of the first two categories

	def self.raw_list
		[
			[	"us_3d_printing",
				"stipulations",
				[
					[],
					["3d_printing"],
					["datadump"],
					["US"],
					[]
				],
				["no_state","CA","NY"]
			],
			[	"US-CA-3d_printing",
				"cst",
				[
					"US",
					"CA",
					"3d_printing"
				],
				nil,
				nil
			],
			[	"US-NY-3d_printing",
				"cst",
				[
					"US",
					"NY",
					"3d_printing"
				],
				nil,
				nil
			],		
			[	"US-MI-3d_printing",
				"cst",
				[
					"US",
					"MI",
					"3d_printing"
				],
				nil,
				nil
			],
			[	"US-PA-3d_printing",
				"cst",
				[
					"US",
					"PA",
					"3d_printing"
				],
				nil,
				nil
			],									
			[ "us_sls",
				"stipulations",
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
				"stipulations",
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
				"stipulations",
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
				"stipulations",
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