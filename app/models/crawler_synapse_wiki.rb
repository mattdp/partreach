
class CrawlerSynapseWiki
  require 'mechanize'
  require 'uri'

  #goal of this method is to get the source file for every vendor page in the wiki
  def self.download_wiki_pages
    mech = CrawlerSynapseWiki.login

    Dir.mkdir('wikipages') unless File.exist?('wikipages')
    wiki_pages = CrawlerSynapseWiki.wiki_pages
    wiki_pages.each do |page_link|
      filename = page_link[1].gsub(/\W+/, "_")
      url = "https://wiki.synapse.com#{page_link[0]}"
      puts "#{filename} : #{url}"
      File.open("wikipages/#{filename}", "w:ASCII-8BIT") do |file|
        page = mech.get url
        file.write page.content
      end
    end

    # TODO log out (put in rescue block)
  end

  def self.login
    #heavily drawing upon http://docs.seattlerb.org/mechanize/EXAMPLES_rdoc.html
    mech = Mechanize.new
    mech.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
    login_page = mech.get('https://sso.synapse.com/login')

    login_page.form_with(id: "login-form") do |f|
      f.username = "supply.better"
      f.password = "w!ndyNail22"
    end.click_button

    mech
  end

  #goal of this method is to take an individual source file and create the correct information in synapse's org
  #using a bunch of iteration and checking instead of regex, since that's not available via xpath in Rails
  def self.upload_wiki_pages

    #to do
    # => data cleaning strategy - how using the warnings
    # => data cleaning

    #not doing
    # => noncompete (bret says no idea what for)
    # => synapsers that used this one (checked 15, don't have content)
    # => multiple contacts

    #manually will do
    # => attachments
    # => everything in 'revisit'

    skip = [ 
"https://s3.amazonaws.com/supplybetter-synpgs/Introduction_of_the_Vendor_Information_for_Confluence_2_3_",
"https://s3.amazonaws.com/supplybetter-synpgs/Mary_s_learning_Wiki",
"https://s3.amazonaws.com/supplybetter-synpgs/Read_Me",
"https://s3.amazonaws.com/supplybetter-synpgs/Read_Me_for_Confluence_2_3_",
"https://s3.amazonaws.com/supplybetter-synpgs/test",
"https://s3.amazonaws.com/supplybetter-synpgs/ttteeesssttt",
"https://s3.amazonaws.com/supplybetter-synpgs/Coxon",
"https://s3.amazonaws.com/supplybetter-synpgs/The_empty_format_for_vendor_information_list"
    ]

    revisit = [
"https://s3.amazonaws.com/supplybetter-synpgs/SF_Shops_to_try",
"https://s3.amazonaws.com/supplybetter-synpgs/Potential_ME_Vendors_List",
"https://s3.amazonaws.com/supplybetter-synpgs/RPDG_Rapid_Product_Development_Group_Inc_", #dupe
"https://s3.amazonaws.com/supplybetter-synpgs/Pathway_Designs", #dupe
"https://s3.amazonaws.com/supplybetter-synpgs/Vendor_Visits_in_SF",
"https://s3.amazonaws.com/supplybetter-synpgs/Feedback_on_Coxon", #coxon is supplier
"https://s3.amazonaws.com/supplybetter-synpgs/Jemco", #error
"https://wiki.synapse.com/display/Vendors/Altaflex+-+ME+Vendor+Page"
]

    urls = [
"https://s3.amazonaws.com/supplybetter-synpgs/3D_Systems_Inc_formerly_Moeller_Design_",
"https://s3.amazonaws.com/supplybetter-synpgs/3M",
"https://s3.amazonaws.com/supplybetter-synpgs/ABC_Imaging",
"https://s3.amazonaws.com/supplybetter-synpgs/Abrisa_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/A_Brite_Plating",
"https://s3.amazonaws.com/supplybetter-synpgs/Absolute_Manufacturing",
"https://s3.amazonaws.com/supplybetter-synpgs/Accellent",
"https://s3.amazonaws.com/supplybetter-synpgs/Accuratus_Corporation",
"https://s3.amazonaws.com/supplybetter-synpgs/ACM_Holding",
"https://s3.amazonaws.com/supplybetter-synpgs/Acrylic_Concepts",
"https://s3.amazonaws.com/supplybetter-synpgs/Acteron_Corp",
"https://s3.amazonaws.com/supplybetter-synpgs/Acu_Line_Corporation",
"https://s3.amazonaws.com/supplybetter-synpgs/Adhesa_Plate",
"https://s3.amazonaws.com/supplybetter-synpgs/Advanced_Molding_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/Advanced_Prototype_Technologies_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Aetna_Plating",
"https://s3.amazonaws.com/supplybetter-synpgs/AIMMco",
"https://s3.amazonaws.com/supplybetter-synpgs/All_Flex_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Alliance_Packaging",
"https://s3.amazonaws.com/supplybetter-synpgs/Allied_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/Alljack",
"https://s3.amazonaws.com/supplybetter-synpgs/Allpak_Container",
"https://s3.amazonaws.com/supplybetter-synpgs/All_West_Components_amp_Fasteners_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Alternative_Molding_Concepts",
"https://s3.amazonaws.com/supplybetter-synpgs/American_Precision_Protoyping_APP_",
"https://s3.amazonaws.com/supplybetter-synpgs/AmTouch_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Apex_Industries_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Apple_Rubber",
"https://s3.amazonaws.com/supplybetter-synpgs/Arcana_Precision_Machine",
"https://s3.amazonaws.com/supplybetter-synpgs/Argo_Spring_Manufacturing_Co_",
"https://s3.amazonaws.com/supplybetter-synpgs/Arlington_Plating_Company_Select_Connect_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/ARRK",
"https://s3.amazonaws.com/supplybetter-synpgs/Artcraft_Plating_amp_Finishing",
"https://s3.amazonaws.com/supplybetter-synpgs/Asahi_Group",
"https://s3.amazonaws.com/supplybetter-synpgs/ASH_Industries",
"https://s3.amazonaws.com/supplybetter-synpgs/ASKO_Processing_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Astro_Electroplating",
"https://s3.amazonaws.com/supplybetter-synpgs/Aurora_Technologies_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Automated_Metal_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/BAI_China_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Bayer_MaterialScience",
"https://s3.amazonaws.com/supplybetter-synpgs/Blue_Streak",
"https://s3.amazonaws.com/supplybetter-synpgs/Bob_s_Design_Engineering_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Buyken_Metal_Products", #has attachments
"https://s3.amazonaws.com/supplybetter-synpgs/BYD_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Caliber_Precision",
"https://s3.amazonaws.com/supplybetter-synpgs/Capital_Industries_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Cardinal_Paint",
"https://s3.amazonaws.com/supplybetter-synpgs/Cascade_Container",
"https://s3.amazonaws.com/supplybetter-synpgs/Cascade_Engineering_Services_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Cascade_Engineering_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/Cascade_Precision_Incorporated",
"https://s3.amazonaws.com/supplybetter-synpgs/Cascade_Quality_Molding",
"https://s3.amazonaws.com/supplybetter-synpgs/Cashmere_Molding",
"https://s3.amazonaws.com/supplybetter-synpgs/Chicago_White_Metal_Casting",
"https://s3.amazonaws.com/supplybetter-synpgs/ChikaBird",
"https://s3.amazonaws.com/supplybetter-synpgs/Cirexx_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Ciscotec",
"https://s3.amazonaws.com/supplybetter-synpgs/Classic_Components",
"https://s3.amazonaws.com/supplybetter-synpgs/Cofan_USA",
"https://s3.amazonaws.com/supplybetter-synpgs/Cole_ScreenPrint_Inc",
"https://s3.amazonaws.com/supplybetter-synpgs/Component_Supply_Company",
"https://s3.amazonaws.com/supplybetter-synpgs/Component_Surfaces",
"https://s3.amazonaws.com/supplybetter-synpgs/Composite_Applications",
"https://s3.amazonaws.com/supplybetter-synpgs/Concept_Reality",
"https://s3.amazonaws.com/supplybetter-synpgs/Conrad_Manufacturing",
"https://s3.amazonaws.com/supplybetter-synpgs/Constance_Machine",
"https://s3.amazonaws.com/supplybetter-synpgs/Control_Plastics",
"https://s3.amazonaws.com/supplybetter-synpgs/CoorsTek",
"https://s3.amazonaws.com/supplybetter-synpgs/Corning_Glass",
"https://s3.amazonaws.com/supplybetter-synpgs/Creganna_Tactx_Medical",
"https://s3.amazonaws.com/supplybetter-synpgs/Custom_Mold_amp_Design",
"https://s3.amazonaws.com/supplybetter-synpgs/Cybershield",
"https://s3.amazonaws.com/supplybetter-synpgs/CyberTouch_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/CymMetrick",
"https://s3.amazonaws.com/supplybetter-synpgs/Cymmetrik",
"https://s3.amazonaws.com/supplybetter-synpgs/Danco",
"https://s3.amazonaws.com/supplybetter-synpgs/Definitive_Solutions_amp_Technologies_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Designcraft_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/DOTT_Industries",
"https://s3.amazonaws.com/supplybetter-synpgs/Double_D_Mfg",
"https://s3.amazonaws.com/supplybetter-synpgs/Douglas_Corp",
"https://s3.amazonaws.com/supplybetter-synpgs/Douglas_Stamping",
"https://s3.amazonaws.com/supplybetter-synpgs/Duke_Empirical",
"https://s3.amazonaws.com/supplybetter-synpgs/Duray_Plating_Co_",
"https://s3.amazonaws.com/supplybetter-synpgs/DYMAX",
"https://s3.amazonaws.com/supplybetter-synpgs/Dynacast",
"https://s3.amazonaws.com/supplybetter-synpgs/Dynacept",
"https://s3.amazonaws.com/supplybetter-synpgs/E_Fab",
"https://s3.amazonaws.com/supplybetter-synpgs/Eika_Kasei_HK_Co_Ltd_",
"https://s3.amazonaws.com/supplybetter-synpgs/Ellsworth",
"https://s3.amazonaws.com/supplybetter-synpgs/Emerald_city_graphics",
"https://s3.amazonaws.com/supplybetter-synpgs/Engent_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Epner_Technology",
"https://s3.amazonaws.com/supplybetter-synpgs/EuroKera",
"https://s3.amazonaws.com/supplybetter-synpgs/Exotic_Tool_Welding",
"https://s3.amazonaws.com/supplybetter-synpgs/Express_Finishing",
"https://s3.amazonaws.com/supplybetter-synpgs/Farwest_Aircraft",
"https://s3.amazonaws.com/supplybetter-synpgs/Farwest_Fabrication",
"https://s3.amazonaws.com/supplybetter-synpgs/Faspro_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Fastenix",
"https://s3.amazonaws.com/supplybetter-synpgs/Fast_Signs",
"https://s3.amazonaws.com/supplybetter-synpgs/Fathom",
"https://s3.amazonaws.com/supplybetter-synpgs/Ferrera_Tooling_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Ferro_Ceramic_Grinding_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Finishing_Unlimited_Inc",
"https://s3.amazonaws.com/supplybetter-synpgs/First_Cut_ProtoLabs_",
"https://s3.amazonaws.com/supplybetter-synpgs/FJM_Security_Products",
"https://s3.amazonaws.com/supplybetter-synpgs/Flock_Tex",
"https://s3.amazonaws.com/supplybetter-synpgs/Fluke_Metal_Products",
"https://s3.amazonaws.com/supplybetter-synpgs/Foctek_Photonics_Inc",
"https://s3.amazonaws.com/supplybetter-synpgs/Form_Factor_Inc",
"https://s3.amazonaws.com/supplybetter-synpgs/Fotofab",
"https://s3.amazonaws.com/supplybetter-synpgs/Frank_Ward_Precision_Prototype",
"https://s3.amazonaws.com/supplybetter-synpgs/FULLRIVER_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Future_Power_Technologies_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Gardico_Incorporated",
"https://s3.amazonaws.com/supplybetter-synpgs/Gary_Hansen",
"https://s3.amazonaws.com/supplybetter-synpgs/General_Foundry_Service",
"https://s3.amazonaws.com/supplybetter-synpgs/General_Super_Plating",
"https://s3.amazonaws.com/supplybetter-synpgs/Genesis_Plastics_Welding",
"https://s3.amazonaws.com/supplybetter-synpgs/Gillaspie_Manufacturing",
"https://s3.amazonaws.com/supplybetter-synpgs/GKS_Services_Corp",
"https://s3.amazonaws.com/supplybetter-synpgs/Global_Lighting_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/GMBattery_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/GM_Nameplate",
"https://s3.amazonaws.com/supplybetter-synpgs/Goldstar_Mold_Shenzhen",
"https://s3.amazonaws.com/supplybetter-synpgs/GPI_Prototype_and_Manufacturing_Services",
"https://s3.amazonaws.com/supplybetter-synpgs/Gumstix_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Harting_MID",
"https://s3.amazonaws.com/supplybetter-synpgs/Henkel_Loctite",
"https://s3.amazonaws.com/supplybetter-synpgs/Herold_Precision_Metals",
"https://s3.amazonaws.com/supplybetter-synpgs/High_End_Finishes",
"https://s3.amazonaws.com/supplybetter-synpgs/High_Energy_Metals_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/HN_Lockwood",
"https://s3.amazonaws.com/supplybetter-synpgs/Ideas_Prototyped_LLC",
"https://s3.amazonaws.com/supplybetter-synpgs/image",
"https://s3.amazonaws.com/supplybetter-synpgs/INCS",
"https://s3.amazonaws.com/supplybetter-synpgs/Industrial_Plating_Corporation",
"https://s3.amazonaws.com/supplybetter-synpgs/Industrial_Service_Co_",
"https://s3.amazonaws.com/supplybetter-synpgs/Innovation_Fabrication",
"https://s3.amazonaws.com/supplybetter-synpgs/INTA_Technologies_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Italix",
"https://s3.amazonaws.com/supplybetter-synpgs/Jet_City_Laser",
"https://s3.amazonaws.com/supplybetter-synpgs/JetEdge",
"https://s3.amazonaws.com/supplybetter-synpgs/Jimani_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/JM_Victor",
"https://s3.amazonaws.com/supplybetter-synpgs/Kaso_Plastics",
"https://s3.amazonaws.com/supplybetter-synpgs/Kelly_Plating_Co_",
"https://s3.amazonaws.com/supplybetter-synpgs/Kemeera_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Kinetics",
"https://s3.amazonaws.com/supplybetter-synpgs/Kingstec",
"https://s3.amazonaws.com/supplybetter-synpgs/Koller_Craft_Plastic_Products",
"https://s3.amazonaws.com/supplybetter-synpgs/Lancaster_Metals_Science_Co_",
"https://s3.amazonaws.com/supplybetter-synpgs/Laser_Cutting_Northwest",
"https://s3.amazonaws.com/supplybetter-synpgs/Laser_Light_Technologies_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Laser_Reproductions",
"https://s3.amazonaws.com/supplybetter-synpgs/Leader_Plating",
"https://s3.amazonaws.com/supplybetter-synpgs/Leader_Tech",
"https://s3.amazonaws.com/supplybetter-synpgs/Lee_Spring",
"https://s3.amazonaws.com/supplybetter-synpgs/Leister",
"https://s3.amazonaws.com/supplybetter-synpgs/LensOne_Lens_Technology",
"https://s3.amazonaws.com/supplybetter-synpgs/Li_Polymer_Batteries_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/LiveWire_Prototyping",
"https://s3.amazonaws.com/supplybetter-synpgs/LPKF",
"https://s3.amazonaws.com/supplybetter-synpgs/Lubrizol_Advanced_Materials",
"https://s3.amazonaws.com/supplybetter-synpgs/Made_3D",
"https://s3.amazonaws.com/supplybetter-synpgs/Magic_Metals",
"https://s3.amazonaws.com/supplybetter-synpgs/Master_Spring_amp_Wire_Form",
"https://s3.amazonaws.com/supplybetter-synpgs/Material_Connexion",
"https://s3.amazonaws.com/supplybetter-synpgs/MC_Custom_Products",
"https://s3.amazonaws.com/supplybetter-synpgs/McKechnie_Vehicle_Components",
"https://s3.amazonaws.com/supplybetter-synpgs/McSweeney_Steel_Co_",
"https://s3.amazonaws.com/supplybetter-synpgs/Metal_Motion",
"https://s3.amazonaws.com/supplybetter-synpgs/MGS_Manufacturing_Group",
"https://s3.amazonaws.com/supplybetter-synpgs/Microform_Precision",
"https://s3.amazonaws.com/supplybetter-synpgs/Micro_Machine_Shop",
"https://s3.amazonaws.com/supplybetter-synpgs/Micron_3D_Printing",
"https://s3.amazonaws.com/supplybetter-synpgs/Midwest_Prototyping",
"https://s3.amazonaws.com/supplybetter-synpgs/Mikros_Engineering",
"https://s3.amazonaws.com/supplybetter-synpgs/Mitsubishi_Engineered_Plastics_MEP_",
"https://s3.amazonaws.com/supplybetter-synpgs/Mobius_Rapid_Prototyping",
"https://s3.amazonaws.com/supplybetter-synpgs/Model_Solution",
"https://s3.amazonaws.com/supplybetter-synpgs/Modelwerks",
"https://s3.amazonaws.com/supplybetter-synpgs/Modern_Engineering",
"https://s3.amazonaws.com/supplybetter-synpgs/Moeller_Design_amp_Development",
"https://s3.amazonaws.com/supplybetter-synpgs/Mold_Rite",
"https://s3.amazonaws.com/supplybetter-synpgs/Molex_Antenna_MID_Division",
"https://s3.amazonaws.com/supplybetter-synpgs/Motion_Mechanisms",
"https://s3.amazonaws.com/supplybetter-synpgs/MPC_Plating",
"https://s3.amazonaws.com/supplybetter-synpgs/National_Instruments",
"https://s3.amazonaws.com/supplybetter-synpgs/Nebula_Design",
"https://s3.amazonaws.com/supplybetter-synpgs/NIC",
"https://s3.amazonaws.com/supplybetter-synpgs/Nissha_USA",
"https://s3.amazonaws.com/supplybetter-synpgs/Northern_Engraving",
"https://s3.amazonaws.com/supplybetter-synpgs/Northwest_Etch_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/Oakdale_Precision",
"https://s3.amazonaws.com/supplybetter-synpgs/Odyssey_Plastics",
"https://s3.amazonaws.com/supplybetter-synpgs/OmniFab",
"https://s3.amazonaws.com/supplybetter-synpgs/Omnitech",
"https://s3.amazonaws.com/supplybetter-synpgs/O_Rings_West",
"https://s3.amazonaws.com/supplybetter-synpgs/PacTec",
"https://s3.amazonaws.com/supplybetter-synpgs/PacWest_Sales",
"https://s3.amazonaws.com/supplybetter-synpgs/Pad_Printing_Services_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Pathway_design",
"https://s3.amazonaws.com/supplybetter-synpgs/Pearce_Design_LLC",
"https://s3.amazonaws.com/supplybetter-synpgs/Pegasus_Northwest",
"https://s3.amazonaws.com/supplybetter-synpgs/Pequot_Tool_and_Mfg_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Peridot_Corp_",
"https://s3.amazonaws.com/supplybetter-synpgs/Pinehurst",
"https://s3.amazonaws.com/supplybetter-synpgs/Pioneer_Metal_Finishing",
"https://s3.amazonaws.com/supplybetter-synpgs/Plastic_Assembly_Systems_PAS_",
"https://s3.amazonaws.com/supplybetter-synpgs/Plastic_Innovations",
"https://s3.amazonaws.com/supplybetter-synpgs/Plastic_Metal_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/Plastic_Platers_Inc",
"https://s3.amazonaws.com/supplybetter-synpgs/PolyOne",
"https://s3.amazonaws.com/supplybetter-synpgs/Pro_CNC_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Production_Plating",
"https://s3.amazonaws.com/supplybetter-synpgs/ProtoCafe",
"https://s3.amazonaws.com/supplybetter-synpgs/Protocam",
"https://s3.amazonaws.com/supplybetter-synpgs/Protolabs",
"https://s3.amazonaws.com/supplybetter-synpgs/Protomold",
"https://s3.amazonaws.com/supplybetter-synpgs/Proto_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/Prototek_Sheetmetal_Fabrication_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Proven_Process_Medical_Devices",
"https://s3.amazonaws.com/supplybetter-synpgs/Providence_Metallizing",
"https://s3.amazonaws.com/supplybetter-synpgs/PTA_Plastics",
"https://s3.amazonaws.com/supplybetter-synpgs/Pulse_Technologies_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Quaker_City_Plating",
"https://s3.amazonaws.com/supplybetter-synpgs/Qualitel_Corp_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Queen_City_Plating",
"https://s3.amazonaws.com/supplybetter-synpgs/Quickparts_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Rapid_Sheet_Metal_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Rayotek",
"https://s3.amazonaws.com/supplybetter-synpgs/R_D_Wing",
"https://s3.amazonaws.com/supplybetter-synpgs/Reell_Precision_Manufacturing",
"https://s3.amazonaws.com/supplybetter-synpgs/Reliance_Engineering",
"https://s3.amazonaws.com/supplybetter-synpgs/Reliance_Manufacturing_Corporation",
"https://s3.amazonaws.com/supplybetter-synpgs/RIM_Manufacturing",
"https://s3.amazonaws.com/supplybetter-synpgs/Rimstar",
"https://s3.amazonaws.com/supplybetter-synpgs/RK_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/RMC_Powder_Coating",
"https://s3.amazonaws.com/supplybetter-synpgs/RPDG_Rapid_Product_Development_Group_",
"https://s3.amazonaws.com/supplybetter-synpgs/RTP_Plastics_Company",
"https://s3.amazonaws.com/supplybetter-synpgs/Ryerson",
"https://s3.amazonaws.com/supplybetter-synpgs/Sabic_Innovative_Plastics",
"https://s3.amazonaws.com/supplybetter-synpgs/Saint_Gobain_Performance_Plastics_Corp_",
"https://s3.amazonaws.com/supplybetter-synpgs/Samuel_Pressure_Vessel_Group",
"https://s3.amazonaws.com/supplybetter-synpgs/Savelle_Precision",
"https://s3.amazonaws.com/supplybetter-synpgs/SCHOTT",
"https://s3.amazonaws.com/supplybetter-synpgs/Scicon_Technology",
"https://s3.amazonaws.com/supplybetter-synpgs/Seal_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/Seastrom_Manufacturing_Co_",
"https://s3.amazonaws.com/supplybetter-synpgs/Seattle_Powder_Coat",
"https://s3.amazonaws.com/supplybetter-synpgs/Seattle_Stainless_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Sel_Tech_International",
"https://s3.amazonaws.com/supplybetter-synpgs/Shmaze_Custom_Coatings",
"https://s3.amazonaws.com/supplybetter-synpgs/Siverson_Design",
"https://s3.amazonaws.com/supplybetter-synpgs/Smalley",
"https://s3.amazonaws.com/supplybetter-synpgs/Solid_Concepts",
"https://s3.amazonaws.com/supplybetter-synpgs/SpectraChrome",
"https://s3.amazonaws.com/supplybetter-synpgs/Spectrum_Plastics_Group",
"https://s3.amazonaws.com/supplybetter-synpgs/SS_Optical_Company",
"https://s3.amazonaws.com/supplybetter-synpgs/Stellartech_Research_Corp_",
"https://s3.amazonaws.com/supplybetter-synpgs/Sun_Power_Technologies_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Sunset_Glass",
"https://s3.amazonaws.com/supplybetter-synpgs/Superior_Imprint_Inc",
"https://s3.amazonaws.com/supplybetter-synpgs/TAP_Plastics",
"https://s3.amazonaws.com/supplybetter-synpgs/Teamvantage",
"https://s3.amazonaws.com/supplybetter-synpgs/Tech_Etch_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Terrazign",
"https://s3.amazonaws.com/supplybetter-synpgs/Terrene_Engineering",
"https://s3.amazonaws.com/supplybetter-synpgs/Tharco",
"https://s3.amazonaws.com/supplybetter-synpgs/The_D_R_Templeman_Co_",
"https://s3.amazonaws.com/supplybetter-synpgs/The_QC_Group_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Thin_Metal_Parts",
"https://s3.amazonaws.com/supplybetter-synpgs/TMF_Inc",
"https://s3.amazonaws.com/supplybetter-synpgs/TorqMaster_Intl_",
"https://s3.amazonaws.com/supplybetter-synpgs/TOSS",
"https://s3.amazonaws.com/supplybetter-synpgs/Touch_International_ME_Vendor_Page",
"https://s3.amazonaws.com/supplybetter-synpgs/Trlby",
"https://s3.amazonaws.com/supplybetter-synpgs/Tung_Tai_Group",
"https://s3.amazonaws.com/supplybetter-synpgs/Tung_Tai_Hardware_MFG",
"https://s3.amazonaws.com/supplybetter-synpgs/United_Western_Enterprises_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/US_Micro_Screw",
"https://s3.amazonaws.com/supplybetter-synpgs/VacuCoat_Technologies",
"https://s3.amazonaws.com/supplybetter-synpgs/Vaga_Industries",
"https://s3.amazonaws.com/supplybetter-synpgs/Vector_industries",
"https://s3.amazonaws.com/supplybetter-synpgs/Vision_Plastics",
"https://s3.amazonaws.com/supplybetter-synpgs/Visual_CNC_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Westwood_Precision_Inc_",
"https://s3.amazonaws.com/supplybetter-synpgs/Wise_Welding",
"https://s3.amazonaws.com/supplybetter-synpgs/Wolfram_Manufacturing",
"https://s3.amazonaws.com/supplybetter-synpgs/Zeus_Industries",
    ]

#     test = ["https://s3.amazonaws.com/supplybetter-synpgs/3D_Systems_Inc_formerly_Moeller_Design_",
# "https://s3.amazonaws.com/supplybetter-synpgs/3M",
# "https://s3.amazonaws.com/supplybetter-synpgs/ABC_Imaging",
# "https://s3.amazonaws.com/supplybetter-synpgs/Abrisa_Technologies",
# "https://s3.amazonaws.com/supplybetter-synpgs/A_Brite_Plating",
# "https://s3.amazonaws.com/supplybetter-synpgs/Absolute_Manufacturing",
# "https://s3.amazonaws.com/supplybetter-synpgs/Accellent",
# "https://s3.amazonaws.com/supplybetter-synpgs/Accuratus_Corporation",
# "https://s3.amazonaws.com/supplybetter-synpgs/ACM_Holding",
# "https://s3.amazonaws.com/supplybetter-synpgs/Acrylic_Concepts",
# "https://s3.amazonaws.com/supplybetter-synpgs/Acteron_Corp",
# "https://s3.amazonaws.com/supplybetter-synpgs/Acu_Line_Corporation",
# "https://s3.amazonaws.com/supplybetter-synpgs/Adhesa_Plate",
# "https://s3.amazonaws.com/supplybetter-synpgs/Advanced_Molding_Technologies",
# "https://s3.amazonaws.com/supplybetter-synpgs/Advanced_Prototype_Technologies_Inc_",
# "https://s3.amazonaws.com/supplybetter-synpgs/Aetna_Plating",
# "https://s3.amazonaws.com/supplybetter-synpgs/AIMMco"]

    test = ["https://s3.amazonaws.com/supplybetter-synpgs/Absolute_Manufacturing"]

    carrier = []

    urls.each do |url|
      begin
        page = Nokogiri::HTML(open(url))
        div_wiki_content = page.css('#content > div.wiki-content')
        div_wiki_content_headers = div_wiki_content.css("h2")
        warnings = []

        name = page.css("span#title-text").text.strip

        #who updated, when was last update
        update = page.css("li.page-metadata-modification-info").text.strip

        #NOT WORKING on boykin
        warnings << "Page contains attachments" if page.css("a#content-metadata-attachments").present?

        #bullet points under capabilities, to make into tags
        tags_from_capabilities = [] 
        capability_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("Capabilities")}.first
        if capability_header.present?
          capability_list = capability_header.next_element
          while capability_list.name == "ul"
            capability_list.css("li > text()").each do |li|
              tags_from_capabilities << li.text.strip if li.text.present?
            end
            capability_list = capability_list.next_element
          end
        end
        warnings << "No tags from capabilities" if tags_from_capabilities.empty? 
      
        text_sections = {}
        ["Clients","CompanySynopsis","CoreFocus","HistoryInformation"].each do |section|
          text_sections[section] = ""
          header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?(section)}.first
          if header.present?
            element = header.next_element
            while element.present? and element.name == "p"
              text_sections[section] += element.text.strip unless element.text.strip == "&nbsp"
              element = element.next_element
            end
          end
        end

        #flag if no contact information, otherwise get it
        contact = {}
        contact_header = div_wiki_content_headers.select{|header| header.attributes["id"].value.include?("ContactInformation")}.first
        if contact_header.present?
          contact_paragraph = contact_header.next_element
          while contact_paragraph.present? and contact_paragraph.children.present? and contact_paragraph.name == "p"

            contact_paragraph.children.each do |child|

              text = child.text
              contact[:name] = text.scan(/Contact: (.*)/) if text.scan(/Contact: (.*)/).present?
              contact[:phone] = text.scan(/Phone: (.*)/) if text.scan(/Phone: (.*)/).present?
              contact[:fax] = text.scan(/Fax: (.*)/) if text.scan(/Fax: (.*)/).present?
              contact[:mobile] = text.scan(/Mobile: (.*)/) if text.scan(/Mobile: (.*)/).present?
              contact[:address] = text.scan(/Address: (.*)/) if text.scan(/Address: (.*)/).present?
              contact[:email] = text.scan(/([\w+\-.]+@[a-z\d\-.]+\.[a-z]{1,5})/i) if text.scan(/([\w+\-.]+@[a-z\d\-.]+\.[a-z]{1,5})/i).present?
              #not great, but don't want to engage with URI library when don't know which strings are url-ish
              contact[:website] = text.scan(/([\w\-\.]+\.(com|net|org|edu|gov|cn)(\/\S+)?)/) if (text.scan(/([\w\-\.]+\.(com|net|org|edu|gov|cn)(\/\S+)?)/).present? and text.scan(/(@[\w\-\.]+\.(com|net|org|edu|gov|cn)(\/\S+)?)/).empty?)          
            end

            contact_paragraph = contact_paragraph.next_element
          end
        end

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

        external_longform = ""
        external_longform += "<p>Synapse wiki 'synopsis': #{text_sections["CompanySynopsis"]}</p>" if text_sections["CompanySynopsis"].present?

        internal_longform = ""
        internal_longform += "<p>Synapse wiki 'history': #{text_sections["HistoryInformation"]}</p>" if text_sections["HistoryInformation"].present?
        internal_longform += "<p>Synapse wiki 'clients': #{text_sections["Clients"]}</p>" if text_sections["Clients"].present?
        internal_longform += "<p>Synapse wiki 'focus': #{text_sections["CoreFocus"]}</p>" if text_sections["CoreFocus"].present?

        carrier << {
                warnings: warnings,
                name: name,
                contact: contact,
                external_longform: external_longform,
                internal_longform: internal_longform,
                tags: tags_from_capabilities.concat(tags_from_labels), 
                url: url,
                update: update
              }

        puts "processed #{url}"
      rescue StandardError => e
        puts "error processing #{url} - exception #{e.backtrace}"
      end
    end

    return carrier 

  end

  #CrawlerSynapseWiki.create_provider_from_wiki_data(carrier,Organization.find(1),User.find(1))
  def self.create_provider_from_wiki_data(carrier,organization,user)

    carrier.each do |wiki_content|
      # begin
        provider = Provider.new(name: wiki_content[:name], name_for_link: Provider.proper_name_for_link(wiki_content[:name]), organization_id: organization.id)
        
        contact = wiki_content[:contact]
        provider.url_main = contact[:website]
        provider.address = contact[:address]
        provider.contact_name = contact[:name]
        provider.contact_phone = contact[:phone]
        provider.contact_email = contact[:email]

        provider.external_notes = wiki_content[:external_longform]
        provider.organization_private_notes = wiki_content[:internal_longform]
        provider.import_warnings = wiki_content[:warnings].join("\n") if wiki_content[:warnings].present?
        provider.supplybetter_private_notes = wiki_content[:update]

        provider.source = wiki_content[:url]

        provider.save

        tag_group = TagGroup.find_by_group_name("provider type")
        wiki_content[:tags].each do |tag_name|
          tag = organization.find_or_create_tag!(tag_name,user)
          if tag.present?
            provider.add_tag(tag.id)
          else
            puts "#{tag_name},#{provider.name} ::: warning - find or create tag returned nil."
          end
        end

      # rescue StandardError => e
      #   puts "error processing #{wiki_content[:name]} in create_provider_from_wiki - exception #{e.backtrace}"
      # end
    end
  end
  #UAT: CrawlerSynapseWiki.full_upload_wrapper(Organization.find(1),User.find(1))
  def self.full_upload_wrapper(organization,user)
    CrawlerSynapseWiki.create_provider_from_wiki_data(CrawlerSynapseWiki.upload_wiki_pages,organization,user)
  end

  #for debugging, remove all recent tags and providers
  def self.nuke(safety)
    if safety == "off"
      Provider.where("created_at > '2015-4-13'").map{|p| p.destroy}
      Tag.where("created_at > '2015-4-13'").map{|p| p.destroy}
    end
  end
end