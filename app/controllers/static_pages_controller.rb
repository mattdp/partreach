class StaticPagesController < ApplicationController
  def home
    if current_user.present?
      Event.add_event("User",current_user.id,"loaded home page")
    else
      Event.add_event(nil,nil,"loaded home page")
    end

    if org_access_allowed?
      redirect_to teams_index_path, status: :moved_permanently
    else
      render :layout => "home"
    end

  end

  def getting_started
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
        { person: "David",
          title: "CEO",
          company: "Anybots Inc.",
          site_url: "http://www.anybots.com/",
          logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/anybots-logo.png",
          praise: "We're a robotics company that needs to quickly prove new ideas and rapidly iterate on new products. SupplyBetter has saved us money, time, and stress by helping source our prototype parts. They've found us quality suppliers who can hit our deadlines and budget, letting our mechanical engineers focus on the matters critical to designing our next hardware iteration. Their service is great, we count on them as extended team members, my team uses them all the time, and I am sure Anybots will be using SupplyBetter for a long time to come."
        },
        {
          person: "Jack",
          title: "CEO",
          company: "Velo Labs",
          site_url: "http://www.velo-labs.com/",
          logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/velo_labs-logo.png",
          praise: "Robert and his team have an amazing service for hardware companies.  Finding a supplier for prototyping at cost and schedule is no longer an issue with SupplyBetter.  They had answers for all my questions and even went to the trouble of finding out more answers by talking to suppliers on my behalf. Their services exceeded my expectations."
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
          person: "Jason",
          title: "Mechanical Engineer",
          company: "Matternet",
          site_url: "http://matternet.us",
          logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/matternet-logo.png",
          praise: "The guys at SupplyBetter really know what they're doing.  We had an impossible timeline, and were able to be matched with a supplier in under one hour and subsequently had a part cut for us within the following 24. We do our best to avoid instantaneous demand, but it's a great feeling knowing the guys at SupplyBetter are there to see us through. We'd definitely work with them again."
        },
        {
          person: "Steven",
          title: "President & CEO",
          company: "Freebord Manufacturing",
          site_url: "http://freebord.com/",
          logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/freebord-logo.png",
          praise: "We wanted to use 3D printing to iterate on the design of our next skateboard and SupplyBetter was the perfect solution for us. Their mechanical engineer quickly helped us figure out which metal 3D printing method would work best and got us quotes back in just a few hours. We're impressed with the quality of SupplyBetter's service and are looking forward to working with them again."
        },
        {
          person: "Karl",
          title: "Owner",
          company: "Five And Dime LLC",
          site_url: "",
          logo: "https://s3.amazonaws.com/supplybetter_buyer_logos/five_and_dime_manufacturing-logo.png",
          praise: "SupplyBetter is my choice for 3D printed parts.  I’ve been making prototype parts via FDM and stereolithography since 2003.  Particular parts need higher levels of accuracy and or different methods of construction to validate designs.  Being able to simply send my part files to SupplyBetter and get quotes in a variety of materials and processes, ensures that I get the best parts at the most reasonable price."
        },
        {
          person: "Michael",
          title: "Industrial Designer",
          company: "MTTS - Medical Technology Transfer and Services",
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
