class StaticPagesController < ApplicationController
	def home
		@testimonials = testimonial_array
		@testimonial = @testimonials[rand(0..@testimonials.length-1)]

		@logo_locations_top = ["https://s3.amazonaws.com/supplybetter_buyer_logos/anybots-logo.png",
			"https://s3.amazonaws.com/supplybetter_buyer_logos/frog_design-logo.png",
			"https://s3.amazonaws.com/supplybetter_buyer_logos/velo_labs-logo.png"
			]

		@logo_locations_bottom = ["https://s3.amazonaws.com/supplybetter_buyer_logos/mtts-logo.png",
			"https://s3.amazonaws.com/supplybetter_buyer_logos/cruise_automation-logo.png",
			"https://s3.amazonaws.com/supplybetter_buyer_logos/five_and_dime_manufacturing-logo.png"
			]
	end

	def getting_started
	end

  def questions
  	@content = Question.raw_list
  	@from_supplier_name = Supplier.find(params[:from_supplier]).name if params[:from_supplier]
  end

	def procurement
	end

	def be_a_supplier
		@testimonial_one =
			{
				person: "Chris Kopack",
				title: "Owner",
				company: "Parts Oven",
				praise: "SupplyBetter helps me reach even more customers than ever before. Better yet, their website builds confidence with the clients making sure they are getting the most for their money. This means more repeat business, and higher overall satisfaction. The quote system is fast and worth every penny."
			}
		@testimonial_two = 
			{
				person: "Ian D. Finn",
				title: "President",
				company: "Finnovation Product Development LLC",
				praise: "SupplyBetter has linked my company with several serious buyers of 3D Printing services. SupplyBetter allows me to focus my time on producing parts rather than locating buyers, thus making my work more efficient with less hassle."
			}
	end

	def terms
	end

	def testimonials
		@testimonials = testimonial_array
	end

	def privacy
	end

	def materials
		@data_by_process = [
				{process: "SLS", material: "Nylon (with various blends), ceramics, metals", looking_for: ["Decent mechanical performance","Low-volume production", "Thinner wall thickness than FDM", "Surface detail"], downsides: ["Dimensional stability lower than FDM", "Trapped powder with hollow object", "Porous"], example: ["A run of 20 custom cable brackets"]},
				{process: "SLA", material: "UV Curable Resin", looking_for: ["Flexible applications", "Great resolution"], downsides: ["Increased brittleness", "Degrades over time due with UV exposure"], example: ["A master print for Rapid Casting"]},
				{process: "Industrial FFF (aka FDM)", material: "ABS (with various blends), Polycarbonate, Nylon, Ultem", looking_for: ["Great mechanical performance", "Low-volume production"], downsides: ["Striations from print visible", "Surface detail worse than SLS (unless post-processed)"], example: ["Functional prototype"]},
				{process: "Hobbyist FFF (desktop 3D printers)", material: "ABS, PLA, Nylon", looking_for: ["Low cost", "Quickest method (at low resolution)"], downsides: ["Low accuracy", "Striations from print visible", "Low surface detail (unless post-processed)", "Poor as an end-use part"], example: ["A pair of large hollow wheels"]},
				{process: "Polyjet", material: "Proprietary materials that range from soft rubber to brittle acrylic", looking_for: ["Great accuracy", "Multiple materials"], downsides: ["Poor for end-use parts"], example: ["A 'looks-like' prototype of a new toothbrush design"]}
				]
	end

	private

		def testimonial_array
			[
				{ person: "Ryan",
					title: "Mechanical Engineer",
					company: "Frog Design",
					site_url: "http://www.frogdesign.com/",
					logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/frog_design-logo.png",
					praise: "Across rapid prototyping jobs both large and small, SupplyBetter has delivered multiple quotes quickly every time, helped us build relationships with new prototyping shops, and increased our quality expectations. Even more importantly, they’ve enabled us to complete large prototyping jobs in less time, so that we can focus more on good design and less on procuring parts."
				},		
				{
					person: "Jack",
					title: "CEO",
					company: "Velo Labs",
					site_url: "http://www.velo-labs.com/",
					logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/velo_labs-logo.png",
					praise: "Robert and his team have an amazing service for hardware companies.  Finding a supplier for prototyping at cost and schedule is no longer an issue with SupplyBetter.  They had answers for all my questions and even went to the trouble of finding out more answers by talking to supplier on my behalf. Their services exceeded my expectations."
				},
				{
					person: "Kyle",
					title: "Founder",
					company: "Cruise Automation",
					site_url: "http://signup.getcruise.com/",	
					logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/cruise_automation-logo.png",
					praise: "When I needed some 3d scanning work done in a pinch, SupplyBetter was incredible.  They hooked me up with a great local company that went above and beyond the call of duty to deliver a set of quality 3d scans on-time and on-budget.  I'll definitely be using SupplyBetter again!"
				},	
				{
					person: "Jesse",
					title: "Marketing Coordinator",
					company: "ZT Systems",
					site_url: "http://ztsystems.com/",
					logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/zt_systems-logo.png",
					praise: "SupplyBetter provided an invaluable service in helping us reduce the inherent complexities of a growing industry. By setting out pricing structures in a simple, clear format, SupplyBetter curated the experience and made it a real pleasure."
				},									
				{
					person: "Karl",
					title: "Owner",
					company: "Five And Dime LLC",
					site_url: "",
					logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/five_and_dime_manufacturing-logo.png",
					praise: "SupplyBetter is my choice for 3D printed parts.  I’ve been making prototype parts via FDM and stereolithography since 2003.  Particular parts need higher levels of accuracy and or different methods of construction to validate designs.  Being able so simply send my part files to SupplyBetter and get quotes in a variety of materials and processes, ensures that I get the best parts at the most reasonable price."
				},
				{
					person: "Michael",
					title: "Industrial Designer",
					company: "Independent",
					site_url: "",
					logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/mtts-logo.png",
					praise: "I am an industrial designer working on medical products for the low resource market across Asia. Dealing with SupplyBetter was very smooth and professional. I personally spoke with Robert, who guided me through the options, and then they connected us with the prototyping house that best suited the particular project. I feel SupplyBetter went the extra mile with a special attention to service."
				},
				{
					person: "Leandro",
					title: "Founder",
					company: "TrazeTag",
					site_url: "http://www.trazetag.com/",
					logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/transparent_placeholder-logo.png",
					praise: "SupplyBetter is a great way of finding suppliers. Submitting an RFQ was easy and comparing quotes from suppliers was straightforward. They helped me with the first iteration of my new product, and I will definitely be using them again."
				},				
				{
					person: "Brian",
					title: "Owner",
					company: "Synáspora",
					site_url: "",					
					logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/transparent_placeholder-logo.png",
					praise: "I'm brand new to 3D printing and needed help printing a prototype for a new product idea of mine. SupplyBetter was the perfect place for me. I got personal service and assistance in choosing the right material. Highly recommended!"
				}
			]
		end
	  
end
