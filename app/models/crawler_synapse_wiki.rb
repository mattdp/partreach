class CrawlerSynapseWiki
  require 'mechanize'

  #goal of this method is to get the source file for every vendor page in the wiki
  def self.get_source_files
    #heavily drawing upon http://docs.seattlerb.org/mechanize/EXAMPLES_rdoc.html
    mech = Mechanize.new
    
    # ISSUE with certification + site not letting me in
    # possible help http://stackoverflow.com/questions/8567973/why-does-accessing-a-ssl-site-with-mechanize-on-windows-fail-but-on-mac-work
    # mech.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    login_page = mech.get('https://sso.synapse.com/login?service=https%3A%2F%2Fwiki.synapse.com%2Fhomepage.action')    

    next_page = login_page.form_with(id: "login-form") do |f|
      f.username = "supply.better"
      f.password = "w!ndyNail22"
    end.click_button

    return next_page
  end

  #goal of this method is to take an individual source file and create the correct information in synapse's org
  #using a bunch of iteration and checking instead of regex, since that's not available via xpath in Rails
  def self.upload_wiki_pages

    #missing
    # => synapsers that used this one
    # => company descriptions
    # => logging of when non compete used
    # => notes at bottom

    example_urls = ["https://s3.amazonaws.com/temp_for_uploading/1.html",
      "https://s3.amazonaws.com/temp_for_uploading/2.html",
      "https://s3.amazonaws.com/temp_for_uploading/3.html",
      "https://s3.amazonaws.com/temp_for_uploading/4.html"]

    urls = example_urls #so everything else works once we have the real ones
    carrier = []

    urls.each do |url|
      page = Nokogiri::HTML(open(url))
      div_wiki_content = page.css('#content > div.wiki-content')
      div_wiki_content_headers = div_wiki_content.css("h2")
      warnings = []

      #who updated, when was last update
      update = page.css("li.page-metadata-modification-info").text.strip

      #bullet points under capabilities, to make into tags
      tags_from_capabilities = [] 
      capability_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("Capabilities")}.first
      capability_list = capability_header.next_element
      capability_list.css("li").each do |li|
        tags_from_capabilities << li.text.strip if li.text.present?
      end
      warnings >> "No tags from capabilties" if tags_from_capabilities.empty? 
      
      #flag if noncompete content, handle manually
      nocompete_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("DoNotCompeteWith")}.first
      warnings >> "Noncompete text present" if (nocompete_header.present? and nocompete_header.next_element.text.present? and nocompete_header.next_element.text != "&nbsp")

      #need to check for longform content
      synopsis_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("CompanySynopsis")}.first
      synopsis_text = synopsis_header.next_element.text.strip
      (synopsis_text.present? and synopsis_text != "&nbsp") ? synopsis = synopsis_text : synopsis = nil

      focus_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("CoreFocus")}.first
      focus_text = focus_header.next_element.text.strip
      (focus_text.present? and focus_text != "&nbsp") ? focus = focus_text : focus = nil

      history_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("HistoryInformation")}.first
      history_text = history_header.next_element.text.strip
      (history_text.present? and history_text != "&nbsp") ? history = history_text : history = nil

      #flag if no contact information, otherwise get it
      contact = {}
      contact_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("ContactInformation")}.first
      contact_paragraph = contact_header.next_element.text

      contact[:name] = contact_paragraph.scan(/Contact: (.*)/) if contact_paragraph.scan(/Contact: (.*)/).present?
      contact[:phone] = contact_paragraph.scan(/Phone: (.*)/) if contact_paragraph.scan(/Phone: (.*)/).present?
      contact[:fax] = contact_paragraph.scan(/Fax: (.*)/) if contact_paragraph.scan(/Fax: (.*)/).present?
      contact[:mobile] = contact_paragraph.scan(/Mobile: (.*)/) if contact_paragraph.scan(/Mobile: (.*)/).present?
      contact[:address] = contact_paragraph.scan(/Address: (.*)/) if contact_paragraph.scan(/Address: (.*)/).present?
      contact[:email] = contact_paragraph.scan(/E-mail: (.*)/) if contact_paragraph.scan(/E-mail: (.*)/).present?
      contact[:website] = contact_paragraph.scan(/Website: (.*)/) if contact_paragraph.scan(/Website: (.*)/).present?

      no_contact_info_flag = true
      contact.each do |key,value|
        if (value.empty? or !value[0][0].present?)
          contact[key] = nil
        else
          contact[key] = value[0][0].strip
          no_contact_info_flag = false
        end
      end
      warnings << "No contact information" if no_contact_info_flag

      #labels should become tags, warn if no labels
      label_links = page.css(".label-list > .label-container > .label")
      tags_from_labels = []
      label_links.each do |label_link|
        tags_from_labels << label_link.text.strip if label_link.text.present?
      end
      warnings << "No tags from labels" if tags_from_capabilities.empty? 

      carrier << {tags: tags_from_capabilities.concat(tags_from_labels), 
              warnings: warnings,
              contact: contact,
              url: url,
              update: update,
              longform: "Wiki history: #{history} Wiki focus: #{focus} Wiki synopsis: #{synopsis}"
            }
    end

    return carrier 

  end

  def self.wiki_pages
    [["/display/Vendors/A-Brite+Plating", "A-Brite Plating"],
     ["/display/Vendors/Absolute+Manufacturing", "Absolute Manufacturing"],
     ["/display/Vendors/Acteron+Corp", "Acteron Corp"],
     ["/display/Vendors/Acu-Line+Corporation", "Acu-Line Corporation"],
     ["/display/Vendors/Adhesa+Plate", "Adhesa Plate"],
     ["/display/Vendors/Aetna+Plating", "Aetna Plating"],
     ["/display/Vendors/All+Flex+-+ME+Vendor+Page", "All Flex - ME Vendor Page"],
     ["/display/Vendors/Allied+Technologies", "Allied Technologies"],
     ["/display/Vendors/Alljack", "Alljack"],
     ["/pages/viewpage.action?pageId=23658946", "Argo Spring Manufacturing Co."],
     ["/pages/viewpage.action?pageId=23659591",
      "Artcraft Plating &amp; Finishing"],
     ["/pages/viewpage.action?pageId=23659311", "ASKO Processing Inc."],
     ["/display/Vendors/Astro+Electroplating", "Astro Electroplating"],
     ["/pages/viewpage.action?pageId=23658919", "Aurora Technologies Inc."],
     ["/display/Vendors/Automated+Metal+Technologies",
      "Automated Metal Technologies"],
     ["/display/Vendors/Blue+Streak", "Blue Streak"],
     ["/pages/viewpage.action?pageId=23659452", "Bob's Design Engineering Inc."],
     ["/display/Vendors/Buyken+Metal+Products", "Buyken Metal Products"],
     ["/pages/viewpage.action?pageId=23659428", "Capital Industries Inc."],
     ["/display/Vendors/Cascade+Container", "Cascade Container"],
     ["/display/Vendors/Cascade+Precision+Incorporated",
      "Cascade Precision Incorporated"],
     ["/display/Vendors/Cascade+Quality+Molding", "Cascade Quality Molding"],
     ["/display/Vendors/ChikaBird", "ChikaBird"],
     ["/display/Vendors/Cirexx+-+ME+Vendor+Page", "Cirexx - ME Vendor Page"],
     ["/display/Vendors/Ciscotec", "Ciscotec"],
     ["/display/Vendors/Classic+Components", "Classic Components"],
     ["/display/Vendors/Component+Surfaces", "Component Surfaces"],
     ["/display/Vendors/Composite+Applications", "Composite Applications"],
     ["/display/Vendors/Constance+Machine", "Constance Machine"],
     ["/display/Vendors/Cybershield", "Cybershield"],
     ["/display/Vendors/CyberTouch+-+ME+Vendor+Page",
      "CyberTouch - ME Vendor Page"],
     ["/pages/viewpage.action?pageId=23658810",
      "Definitive Solutions &amp; Technologies, Inc."],
     ["/display/Vendors/DOTT+Industries", "DOTT Industries"],
     ["/display/Vendors/Douglas+Corp", "Douglas Corp"],
     ["/pages/viewpage.action?pageId=23659603", "Duray Plating Co."],
     ["/display/Vendors/Dynacept", "Dynacept"],
     ["/display/Vendors/Emerald+city+graphics", "Emerald city graphics"],
     ["/display/Vendors/Epner+Technology", "Epner Technology"],
     ["/display/Vendors/Express+Finishing", "Express Finishing"],
     ["/display/Vendors/Farwest+Aircraft", "Farwest Aircraft"],
     ["/display/Vendors/Farwest+Fabrication", "Farwest Fabrication"],
     ["/display/Vendors/Finishing+Unlimited+Inc", "Finishing Unlimited Inc"],
     ["/display/Vendors/Form+Factor+Inc", "Form Factor Inc"],
     ["/display/Vendors/Fotofab", "Fotofab"],
     ["/display/Vendors/Frank+Ward+Precision+Prototype",
      "Frank Ward Precision Prototype"],
     ["/display/Vendors/Gardico+Incorporated", "Gardico Incorporated"],
     ["/display/Vendors/Gary+Hansen", "Gary Hansen"],
     ["/display/Vendors/General+Super+Plating", "General Super Plating"],
     ["/display/Vendors/Gillaspie+Manufacturing", "Gillaspie Manufacturing"],
     ["/display/Vendors/High+End+Finishes", "High End Finishes"],
     ["/pages/viewpage.action?pageId=23658651", "High Energy Metals Inc."],
     ["/pages/viewpage.action?pageId=23658802", "Industrial Service Co."],
     ["/display/Vendors/Innovation+Fabrication", "Innovation Fabrication"],
     ["/display/Vendors/Italix", "Italix"],
     ["/display/Vendors/JetEdge", "JetEdge"],
     ["/pages/viewpage.action?pageId=23659307", "Jimani Inc."],
     ["/pages/viewpage.action?pageId=23659601", "Kelly Plating Co."],
     ["/pages/viewpage.action?pageId=23658898", "Kemeera Inc."],
     ["/display/Vendors/Kingstec", "Kingstec"],
     ["/display/Vendors/Koller+Craft+Plastic+Products",
      "Koller Craft Plastic Products"],
     ["/pages/viewpage.action?pageId=23659515", "Lancaster Metals Science Co."],
     ["/pages/viewpage.action?pageId=23659488", "Laser Light Technologies Inc."],
     ["/display/Vendors/Leader+Plating", "Leader Plating"],
     ["/display/Vendors/LiveWire+Prototyping", "LiveWire Prototyping"],
     ["/display/Vendors/MC+Custom+Products", "MC Custom Products"],
     ["/display/Vendors/McKechnie+Vehicle+Components",
      "McKechnie Vehicle Components"],
     ["/display/Vendors/Metal+Motion", "Metal Motion"],
     ["/display/Vendors/Microform+Precision", "Microform Precision"],
     ["/display/Vendors/Model+Solution", "Model Solution"],
     ["/display/Vendors/Modelwerks", "Modelwerks"],
     ["/display/Vendors/Modern+Engineering", "Modern Engineering"],
     ["/pages/viewpage.action?pageId=23659089",
      "3D Systems, Inc. (formerly Moeller Design)"],
     ["/display/Vendors/Mold+Rite", "Mold Rite"],
     ["/display/Vendors/MPC+Plating", "MPC Plating"],
     ["/display/Vendors/NIC", "NIC"],
     ["/display/Vendors/Northwest+Etch+Technologies",
      "Northwest Etch Technologies"],
     ["/display/Vendors/Odyssey+Plastics", "Odyssey Plastics"],
     ["/display/Vendors/OmniFab", "OmniFab"],
     ["/display/Vendors/Omnitech", "Omnitech"],
     ["/display/Vendors/PacTec", "PacTec"],
     ["/display/Vendors/Pathway+design", "Pathway design"],
     ["/display/Vendors/Pathway+Designs", "Pathway Designs"],
     ["/display/Vendors/Pearce+Design+LLC", "Pearce Design LLC"],
     ["/display/Vendors/Pegasus+Northwest", "Pegasus Northwest"],
     ["/pages/viewpage.action?pageId=23659390", "Pequot Tool and Mfg. Inc."],
     ["/pages/viewpage.action?pageId=23658962", "Peridot Corp."],
     ["/display/Vendors/Pioneer+Metal+Finishing", "Pioneer Metal Finishing"],
     ["/display/Vendors/Plastic-Metal+Technologies", "Plastic-Metal Technologies"],
     ["/display/Vendors/Plastic+Platers+Inc", "Plastic Platers Inc"],
     ["/pages/viewpage.action?pageId=23659355", "Pro CNC Inc."],
     ["/display/Vendors/Production+Plating", "Production Plating"],
     ["/display/Vendors/Protocam", "Protocam"],
     ["/display/Vendors/Protomold", "Protomold"],
     ["/display/Vendors/Proto+Technologies", "Proto Technologies"],
     ["/pages/viewpage.action?pageId=23659000",
      "Prototek Sheetmetal Fabrication Inc."],
     ["/display/Vendors/Providence+Metallizing", "Providence Metallizing"],
     ["/pages/viewpage.action?pageId=23659492", "The QC Group, Inc."],
     ["/display/Vendors/Quaker+City+Plating", "Quaker City Plating"],
     ["/display/Vendors/Qualitel+Corp.+-+ME+Vendor+Page",
      "Qualitel Corp. - ME Vendor Page"],
     ["/display/Vendors/Queen+City+Plating", "Queen City Plating"],
     ["/pages/viewpage.action?pageId=23659545", "Quickparts Inc."],
     ["/display/Vendors/R.D.+Wing", "R.D. Wing"],
     ["/pages/viewpage.action?pageId=23658987", "Rapid Sheet Metal Inc."],
     ["/pages/viewpage.action?pageId=24052027", "Read Me (for Confluence 2.3)"],
     ["/display/Vendors/Reliance+Manufacturing+Corporation",
      "Reliance Manufacturing Corporation"],
     ["/display/Vendors/Ryerson", "Ryerson"],
     ["/display/Vendors/Scicon+Technology", "Scicon Technology"],
     ["/display/Vendors/Seal+Technologies", "Seal Technologies"],
     ["/pages/viewpage.action?pageId=23658985", "Seattle Stainless Inc."],
     ["/display/Vendors/Shmaze+Custom+Coatings", "Shmaze Custom Coatings"],
     ["/display/Vendors/Smalley", "Smalley"],
     ["/display/Vendors/Solid+Concepts", "Solid Concepts"],
     ["/display/Vendors/SpectraChrome", "SpectraChrome"],
     ["/display/Vendors/SS+Optical+Company", "SS Optical Company"],
     ["/display/Vendors/Sunset+Glass", "Sunset Glass"],
     ["/display/Vendors/Tech-Etch+-+ME+Vendor+Page", "Tech-Etch - ME Vendor Page"],
     ["/pages/viewpage.action?pageId=23659224",
      "Introduction of the Vendor Information (for Confluence 2.3)"],
     ["/display/Vendors/The+empty+format+for+vendor+information+list",
      "The empty format for vendor information list"],
     ["/display/Vendors/Terrene+Engineering", "Terrene Engineering"],
     ["/display/Vendors/Tharco", "Tharco"],
     ["/pages/viewpage.action?pageId=23658953", "The D.R. Templeman Co."],
     ["/display/Vendors/TMF++Inc", "TMF  Inc"],
     ["/display/Vendors/Touch+International+-+ME+Vendor+Page",
      "Touch International - ME Vendor Page"],
     ["/pages/viewpage.action?pageId=23659532",
      "United Western Enterprises, Inc."],
     ["/display/Vendors/VacuCoat+Technologies", "VacuCoat Technologies"],
     ["/display/Vendors/Vaga+Industries", "Vaga Industries"],
     ["/display/Vendors/Vector+industries", "Vector industries"],
     ["/display/Vendors/Vision+Plastics", "Vision Plastics"],
     ["/pages/viewpage.action?pageId=21725263", "Visual CNC Inc."],
     ["/pages/viewpage.action?pageId=23659386", "Westwood Precision Inc."],
     ["/display/Vendors/Wise+Welding", "Wise Welding"],
     ["/display/Vendors/Laser+Cutting+Northwest", "Laser Cutting Northwest"],
     ["/pages/viewpage.action?pageId=48103974", "Designcraft Inc."],
     ["/display/Vendors/General+Foundry+Service", "General Foundry Service"],
     ["/display/Vendors/FJM+Security+Products", "FJM Security Products"],
     ["/display/Vendors/BAI+China+-+ME+Vendor+Page", "BAI China - ME Vendor Page"],
     ["/display/Vendors/Sun+Power+Technologies+-+ME+Vendor+Page",
      "Sun Power Technologies - ME Vendor Page"],
     ["/display/Vendors/FULLRIVER+-+ME+Vendor+Page", "FULLRIVER - ME Vendor Page"],
     ["/display/Vendors/Future+Power+Technologies+-+ME+Vendor+Page",
      "Future Power Technologies - ME Vendor Page"],
     ["/display/Vendors/Li-Polymer+Batteries+-+ME+Vendor+Page",
      "Li-Polymer Batteries - ME Vendor Page"],
     ["/display/Vendors/BYD+-+ME+Vendor+Page", "BYD - ME Vendor Page"],
     ["/display/Vendors/GMBattery+-+ME+Vendor+Page", "GMBattery - ME Vendor Page"],
     ["/display/Vendors/Goldstar+Mold+-+Shenzhen", "Goldstar Mold - Shenzhen"],
     ["/display/Vendors/US+Micro+Screw", "US Micro Screw"],
     ["/display/Vendors/Nebula+Design", "Nebula Design"],
     ["/pages/viewpage.action?pageId=51085835", "TorqMaster Intl."],
     ["/pages/viewpage.action?pageId=51086027", "Stellartech Research Corp."],
     ["/display/Vendors/Duke+Empirical", "Duke Empirical"],
     ["/display/Vendors/Accellent", "Accellent"],
     ["/pages/viewpage.action?pageId=51086036", "Pulse Technologies, Inc."],
     ["/display/Vendors/Creganna-Tactx+Medical", "Creganna-Tactx Medical"],
     ["/display/Vendors/Proven+Process+Medical+Devices",
      "Proven Process Medical Devices"],
     ["/display/Vendors/Flock-Tex", "Flock-Tex"],
     ["/display/Vendors/Acrylic+Concepts", "Acrylic Concepts"],
     ["/display/Vendors/Jemco", "Jemco"],
     ["/pages/viewpage.action?pageId=54558817",
      "Moeller Design &amp; Development"],
     ["/display/Vendors/PacWest+Sales", "PacWest Sales"],
     ["/display/Vendors/AmTouch+-+ME+Vendor+Page", "AmTouch - ME Vendor Page"],
     ["/pages/viewpage.action?pageId=56820074", "Pad Printing Services Inc."],
     ["/display/Vendors/Cole+ScreenPrint+Inc", "Cole ScreenPrint Inc"],
     ["/display/Vendors/Industrial+Plating+Corporation",
      "Industrial Plating Corporation"],
     ["/display/Vendors/Superior+Imprint+Inc", "Superior Imprint Inc"],
     ["/display/Vendors/GM+Nameplate", "GM Nameplate"],
     ["/display/Vendors/GKS+Services+Corp", "GKS Services Corp"],
     ["/display/Vendors/Fast+Signs", "Fast Signs"],
     ["/display/Vendors/Arcana+Precision+Machine", "Arcana Precision Machine"],
     ["/pages/viewpage.action?pageId=57508034", "Ferro-Ceramic Grinding, Inc."],
     ["/pages/viewpage.action?pageId=57508050", "INTA Technologies, Inc."],
     ["/display/Vendors/CoorsTek", "CoorsTek"],
     ["/display/Vendors/National+Instruments", "National Instruments"],
     ["/display/Vendors/Mikros+Engineering", "Mikros Engineering"],
     ["/display/Vendors/Read+Me", "Read Me"],
     ["/display/Vendors/ttteeesssttt", "ttteeesssttt"],
     ["/display/Vendors/test", "test"],
     ["/display/Vendors/Danco", "Danco"],
     ["/display/Vendors/RIM+Manufacturing", "RIM Manufacturing"],
     ["/display/Vendors/Rimstar", "Rimstar"],
     ["/display/Vendors/AIMMco", "AIMMco"],
     ["/display/Vendors/Spectrum+Plastics+Group", "Spectrum Plastics Group"],
     ["/display/Vendors/Vendor+Visits+in+SF", "Vendor Visits in SF"],
     ["/pages/viewpage.action?pageId=61279737", "Eika Kasei (HK) Co., Ltd."],
     ["/display/Vendors/Seattle+Powder+Coat", "Seattle Powder Coat"],
     ["/display/Vendors/Exotic+Tool+Welding", "Exotic Tool Welding"],
     ["/display/Vendors/Caliber+Precision", "Caliber Precision"],
     ["/display/Vendors/INCS", "INCS"],
     ["/display/Vendors/3M", "3M"],
     ["/pages/viewpage.action?pageId=62062878", "Master Spring &amp; Wire Form"],
     ["/pages/viewpage.action?pageId=62062920",
      "Advanced Prototype Technologies, Inc."],
     ["/display/Vendors/ABC+Imaging", "ABC Imaging"],
     ["/pages/viewpage.action?pageId=62914604", "Apex Industries, Inc."],
     ["/pages/viewpage.action?pageId=62915081",
      "RPDG (Rapid Product Development Group, Inc.)"],
     ["/display/Vendors/RK+Technologies", "RK Technologies"],
     ["/display/Vendors/Leader+Tech", "Leader Tech"],
     ["/pages/viewpage.action?pageId=63733894",
      "Cascade Engineering Services Inc."],
     ["/display/Vendors/Cascade+Engineering+Technologies",
      "Cascade Engineering Technologies"],
     ["/display/Vendors/Conrad+Manufacturing", "Conrad Manufacturing"],
     ["/pages/viewpage.action?pageId=63734353",
      "Saint-Gobain Performance Plastics Corp."],
     ["/display/Vendors/Double+D+Mfg", "Double D Mfg"],
     ["/display/Vendors/Mobius+Rapid+Prototyping", "Mobius Rapid Prototyping"],
     ["/display/Vendors/Henkel+Loctite", "Henkel Loctite"],
     ["/display/Vendors/RMC+Powder+Coating", "RMC Powder Coating"],
     ["/display/Vendors/Zeus+Industries", "Zeus Industries"],
     ["/display/Vendors/Jet+City+Laser", "Jet City Laser"],
     ["/display/Vendors/Wolfram+Manufacturing", "Wolfram Manufacturing"],
     ["/display/Vendors/Material+Connexion", "Material Connexion"],
     ["/display/Vendors/PTA+Plastics", "PTA Plastics"],
     ["/display/Vendors/Mary%27s+learning+Wiki", "Mary's learning Wiki"],
     ["/pages/viewpage.action?pageId=66816058", "First Cut (ProtoLabs)"],
     ["/display/Vendors/Motion+Mechanisms", "Motion Mechanisms"],
     ["/display/Vendors/O-Rings+West", "O-Rings West"],
     ["/display/Vendors/Apple+Rubber", "Apple Rubber"],
     ["/display/Vendors/Global+Lighting+Technologies",
      "Global Lighting Technologies"],
     ["/display/Vendors/GPI+Prototype+and+Manufacturing+Services",
      "GPI Prototype and Manufacturing Services"],
     ["/display/Vendors/Plastic+Innovations", "Plastic Innovations"],
     ["/display/Vendors/Sel-Tech+International", "Sel-Tech International"],
     ["/display/Vendors/Advanced+Molding+Technologies",
      "Advanced Molding Technologies"],
     ["/display/Vendors/ProtoCafe", "ProtoCafe"],
     ["/display/Vendors/Teamvantage", "Teamvantage"],
     ["/display/Vendors/MGS+Manufacturing+Group", "MGS Manufacturing Group"],
     ["/display/Vendors/Kaso+Plastics", "Kaso Plastics"],
     ["/display/Vendors/ARRK", "ARRK"],
     ["/display/Vendors/Douglas+Stamping", "Douglas Stamping"],
     ["/display/Vendors/Dynacast", "Dynacast"],
     ["/display/Vendors/SCHOTT", "SCHOTT"],
     ["/display/Vendors/EuroKera", "EuroKera"],
     ["/display/Vendors/Trlby", "Trlby"],
     ["/display/Vendors/TOSS", "TOSS"],
     ["/display/Vendors/Leister", "Leister"],
     ["/display/Vendors/LPKF", "LPKF"],
     ["/pages/viewpage.action?pageId=74811353", "Plastic Assembly Systems (PAS)"],
     ["/display/Vendors/Rayotek", "Rayotek"],
     ["/display/Vendors/Abrisa+Technologies", "Abrisa Technologies"],
     ["/pages/viewpage.action?pageId=75465402", "Faspro Inc."],
     ["/pages/viewpage.action?pageId=75465881", "Ferrera Tooling Inc."],
     ["/display/Vendors/Potential+ME+Vendors+List", "Potential ME Vendors List"],
     ["/display/Vendors/Ideas+Prototyped+LLC", "Ideas Prototyped LLC"],
     ["/display/Vendors/Reell+Precision+Manufacturing",
      "Reell Precision Manufacturing"],
     ["/display/Vendors/Lee+Spring", "Lee Spring"],
     ["/display/Vendors/Alternative+Molding+Concepts",
      "Alternative Molding Concepts"],
     ["/display/Vendors/Laser+Reproductions", "Laser Reproductions"],
     ["/display/Vendors/Herold+Precision+Metals", "Herold Precision Metals"],
     ["/display/Vendors/Genesis+Plastics+Welding", "Genesis Plastics Welding"],
     ["/display/Vendors/Kinetics", "Kinetics"],
     ["/display/Vendors/Pinehurst", "Pinehurst"],
     ["/display/Vendors/Terrazign", "Terrazign"],
     ["/display/Vendors/CymMetrick", "CymMetrick"],
     ["/display/Vendors/Northern+Engraving", "Northern Engraving"],
     ["/display/Vendors/Micro+Machine+Shop", "Micro Machine Shop"],
     ["/display/Vendors/SF+Shops+to+try", "SF Shops to try"],
     ["/display/Vendors/Cardinal+Paint", "Cardinal Paint"],
     ["/display/Vendors/DYMAX", "DYMAX"],
     ["/display/Vendors/Ellsworth", "Ellsworth"],
     ["/display/Vendors/Sabic+Innovative+Plastics", "Sabic Innovative Plastics"],
     ["/pages/viewpage.action?pageId=81232404",
      "Arlington Plating Company / Select Connect Technologies"],
     ["/display/Vendors/Bayer+MaterialScience", "Bayer MaterialScience"],
     ["/display/Vendors/TAP+Plastics", "TAP Plastics"],
     ["/display/Vendors/RTP+Plastics+Company", "RTP Plastics Company"],
     ["/pages/viewpage.action?pageId=81233030",
      "Mitsubishi Engineered Plastics (MEP)"],
     ["/display/Vendors/Lubrizol+Advanced+Materials",
      "Lubrizol Advanced Materials"],
     ["/display/Vendors/PolyOne", "PolyOne"],
     ["/pages/viewpage.action?pageId=81233116", "LensOne/Lens Technology"],
     ["/display/Vendors/Corning+Glass", "Corning Glass"],
     ["/pages/viewpage.action?pageId=81233147", "Custom Mold &amp; Design"],
     ["/display/Vendors/Cymmetrik", "Cymmetrik"],
     ["/display/Vendors/Harting+MID", "Harting MID"],
     ["/display/Vendors/Nissha+USA", "Nissha USA"],
     ["/display/Vendors/Fathom", "Fathom"],
     ["/pages/viewpage.action?pageId=81888724", "Molex Antenna/MID Division"],
     ["/display/Vendors/Micron+3D+Printing", "Micron 3D Printing"],
     ["/display/Vendors/Fluke+Metal+Products", "Fluke Metal Products"],
     ["/display/Vendors/Thin+Metal+Parts", "Thin Metal Parts"],
     ["/display/Vendors/Component+Supply+Company", "Component Supply Company"],
     ["/display/Vendors/HN+Lockwood", "HN Lockwood"],
     ["/display/Vendors/Control+Plastics", "Control Plastics"],
     ["/display/Vendors/Asahi+Group", "Asahi Group"],
     ["/display/Vendors/Feedback+on+Coxon", "Feedback on Coxon"],
     ["/display/Vendors/Coxon", "Coxon"],
     ["/display/Vendors/Tung+Tai+Group", "Tung Tai Group"],
     ["/pages/viewpage.action?pageId=84083378",
      "American Precision Protoyping (APP)"],
     ["/display/Vendors/Oakdale+Precision", "Oakdale Precision"],
     ["/display/Vendors/image", "image"],
     ["/display/Vendors/Alliance+Packaging", "Alliance Packaging"],
     ["/display/Vendors/Allpak+Container", "Allpak Container"],
     ["/display/Vendors/ASH+Industries", "ASH Industries"],
     ["/display/Vendors/Reliance+Engineering", "Reliance Engineering"],
     ["/display/Vendors/Protolabs", "Protolabs"],
     ["/display/Vendors/Tung+Tai+Hardware+MFG", "Tung Tai Hardware MFG"],
     ["/display/Vendors/Foctek+Photonics%2C+Inc", "Foctek Photonics, Inc"],
     ["/display/Vendors/JM+Victor", "JM Victor"],
     ["/display/Vendors/Cofan+USA", "Cofan USA"],
     ["/display/Vendors/Accuratus+Corporation", "Accuratus Corporation"],
     ["/display/Vendors/ACM+Holding", "ACM Holding"],
     ["/pages/viewpage.action?pageId=24608901",
      "All West Components &amp; Fasteners Inc."],
     ["/display/Vendors/Altaflex+-+ME+Vendor+Page", "Altaflex - ME Vendor Page"],
     ["/display/Vendors/Cashmere+Molding", "Cashmere Molding"],
     ["/display/Vendors/Chicago+White+Metal+Casting",
      "Chicago White Metal Casting"],
     ["/display/Vendors/Concept+Reality", "Concept Reality"],
     ["/display/Vendors/E-Fab", "E-Fab"],
     ["/display/Vendors/Engent+-+ME+Vendor+Page", "Engent - ME Vendor Page"],
     ["/display/Vendors/Fastenix", "Fastenix"],
     ["/display/Vendors/Gumstix+-+ME+Vendor+Page", "Gumstix - ME Vendor Page"],
     ["/display/Vendors/Made+3D", "Made 3D"],
     ["/display/Vendors/Magic+Metals", "Magic Metals"],
     ["/pages/viewpage.action?pageId=24608869", "McSweeney Steel Co."],
     ["/display/Vendors/Midwest+Prototyping", "Midwest Prototyping"],
     ["/pages/viewpage.action?pageId=33718321",
      "RPDG (Rapid Product Development Group)"],
     ["/display/Vendors/Samuel+Pressure+Vessel+Group",
      "Samuel Pressure Vessel Group"],
     ["/display/Vendors/Savelle+Precision", "Savelle Precision"],
     ["/pages/viewpage.action?pageId=24052149", "Seastrom Manufacturing Co."],
     ["/display/Vendors/Siverson+Design", "Siverson Design"]
   ]
  end

end