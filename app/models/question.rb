class Question

	# def self.all
	# end

	def self.get_option_details(name,option_name)
		list = Question.raw_list
		if list[name] and list[name][:options]
			return Question.raw_list[name][:options][option_name.to_sym]
		else
			return nil
		end
	end

	# def initialize
	# end

	# def self.get(name)
	# end

	def self.raw_list
		list = {
  		experience: {
				main_header: "Experience",
				sub_header: "Are you experienced with this sort of job?",
				options:
				{
					experienced: 
					{
						summary: "am experienced",
						punchy: "Experienced",
						detail: "I know the details. Let me tell you exactly what I need."
					},
					rookie:
					{
						summary: "am still learning",
						punchy: "Still learning",
						detail: "I'm not sure what's best for the job. I could use a little help."
					}
				}
  		},
  		priority: {
  			main_header: "Priorities",
  			sub_header: "What do you care about most?",
  			options:
  			{
  				speed:
  				{
  					summary: "speed",
  					punchy: "Speed",
  					detail: "This needs to be done soon."
  				},
  				quality:
  				{
  					summary: "quality",
  					punchy: "Quality",
  					detail: "The details have to be exactly right."
  				},
  				cost:
  				{
  					summary: "cost",
  					punchy: "Cost",
  					detail: "Find me an inexpensive supplier."
  				}
  			}
  		},
  		manufacturing: {
  			main_header: "Manufacturing method",
  			sub_header: "How do you think this should be made?",
  			options:
  			{
  				printing:
  				{
  					summary: "should be",
  					punchy: "3D printing",
  					detail: "I think this should be 3D printed."
  				},
  				other:
  				{
  					summary: "shouldn't be",
  					punchy: "Some other method",
  					detail: "3D printing isn't appropriate for this."
  				},
  				unknown:
  				{
  					summary: "might be",
  					punchy: "I don't know",
  					detail: "I don't know what's best."
  				}
  			}
  		}
  	}
	end

end