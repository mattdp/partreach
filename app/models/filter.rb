class Filter
	attr_reader :name, :format, :limits, :up_front_states

	def self.all
		all = {}
		Filter.raw_list.each do |line|
			all[line[0]] = new(line[0],line[1],line[2],line[3])
		end
		return all
	end

	def initialize(name,format,limits,up_front_states)
		@name = name
		@format = format
		@up_front_states = up_front_states

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
					["US"]
				],
				["no_state","CA"]
			],
			[	"US-CA-3d_printing",
				"cst",
				[
					"US",
					"CA",
					"3d_printing"
				],
				nil
			]
		]
	end

end