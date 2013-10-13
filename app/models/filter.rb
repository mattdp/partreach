class Filter

	def self.all
		all = {}
		Filter.raw_list.each do |line|
			all[line[0]] = new(line[0],line[1],line[2])
		end
		return all
	end

	def intialize(name,format,info)
		@name = name
		answer = {format: format}
		if format == "tcs"
			a,b,c = :country,:state,:tag
			answer[a], answer[b], answer[c] = info[0], info[1], info[2]
		elsif format == "stipulations"
			a,b = :and_style_haves, :or_style_haves
			c,d = :and_style_have_nots, :countries
			answer[a], answer[b], answer[c], answer[d] = info[0], info[1], info[2], info[3]
		else
			return nil
		end
		return answer
	end

	def self.get(name)
		return Filter.all[name]
	end

  #index is {name => [[mandatory have tags 'ands'],[have one of to get into set 'ors'][ mandatory have nots tags],[countries]]}
  # => needs to have at least one thing in one of the first two categories

	def self.raw_list
		[
			["us_3d_printing","stipulations",[[],["3d_printing"],["datadump"],["US"]]],
			["US-CA-3dprinting","cst",["US","CA","3dprinting"]]
		]
	end

end