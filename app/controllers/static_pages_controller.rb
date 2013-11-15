class StaticPagesController < ApplicationController
	def home
		@testimonials = [
			{
				person: "Jack Al-Kahwati",
				title: "CEO",
				company: "Velo Labs",
				praise: "Robert and his team have an amazing service for hardware companies.  Finding a supplier for prototyping at cost and schedule is no longer an issue with SupplyBetter.  They had answers for all my questions and even went to the trouble of finding out more answers by talking to supplier on my behalf. Their services exceeded my expectations."
			},
			{
				person: "Leandro Margulis",
				title: "Founder",
				company: "TrazeTag",
				praise: "SupplyBetter is a great way of finding suppliers. Submitting an RFQ was easy and comparing quotes from suppliers was straightforward. They helped me with the first iteration of my new product, and I will definitely be using them again."
			},
			{
				person: "Karl Boucher",
				title: "Owner",
				company: "Five And Dime LLC",
				praise: "SupplyBetter is my choice for 3D printed parts.  I’ve been making prototype parts via FDM and stereolithography since 2003.  Particular parts need higher levels of accuracy and or different methods of construction to validate designs.  Being able so simply send my part files to SupplyBetter and get quotes in a variety of materials and processes, ensures that I get the best parts at the most reasonable price.  I’m more productive as well since I spend more time designing instead of running a desktop 3D printer.  I’ve used SupplyBetter for prototyping injection molded parts as well as for direct digital manufacture parts and have been very pleased with the results."
			},
			{
				person: "Michael",
				title: "Industrial Designer",
				company: "Independent",
				praise: "I am an industrial designer working on medical products for the low resource market across Asia. Dealing with SupplyBetter was very smooth and professional. I personally spoke with Robert, who guided me through the options, and then they connected us with the prototyping house that best suited the particular project. I feel SupplyBetter went the extra mile with a special attention to service."
			}
		]
		@testimonial = @testimonials[rand(0..@testimonials.length-1)]
	end

	def getting_started
	end

  def questions
  	@content = {
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

	def procurement
	end

	def be_a_supplier
		@testimonial =
			{
				person: "Chris Kopack",
				title: "Owner",
				company: "Parts Oven",
				praise: "SupplyBetter helps me reach even more customers than ever before. Better yet, their website builds confidence with the clients making sure they are getting the most for their money. This means more repeat business, and higher overall satisfaction. The quote system is fast and worth every penny."
			}
	end

	def terms
	end

	def privacy
	end

	def materials
		@data_by_process = [
				{process: "SLS", material: "Nylon (with various blends), ceramics, metals", looking_for: ["Decent mechanical performance","Low-volume production", "Thinner wall thickness than FDM", "Surface detail"], downsides: ["Dimensional stability lower than FDM", "Trapped powder with hollow object", "Porous"], example: ["A run of 20 custom cable brackets"]},
				{process: "SLA", material: "UV Curable Resin", looking_for: ["Flexible applications", "Great resolution"], downsides: ["Increased brittleness", "Degrades over time due with UV exposure"], example: ["A master print for Rapid Casting"]},
				{process: "Industrial FFF (aka FDM)", material: "ABS (with various blends), Polycarbonate, Nylon, Ultem", looking_for: ["Great mechanical performance", "Low-volume production"], downsides: ["Striations from print visible", "Surface detail worse than SLS (unless post-processed)"], example: ["Functional prototype"]},
				{process: "Hobbyist FFF (desktop 3D printers)", material: "ABS, PLA, Nylon", looking_for: ["Cheap to make", "Quickest method (at low resolution)"], downsides: ["Low accuracy", "Striations from print visible", "Low surface detail (unless post-processed)", "Poor as an end-use part"], example: ["A pair of large hollow wheels"]},
				{process: "Polyjet", material: "Proprietary materials that range from soft rubber to brittle acrylic", looking_for: ["Great accuracy", "Can mix materials"], downsides: ["Poor for end-use parts"], example: ["A 'looks-like' prototype of a new toothbrush design"]}
				]
	end
	  
end
