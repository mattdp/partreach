module Crawlers

  require 'csv'
  
  #highly inflexible, based on "printabase-crawled-data"
  PB_USE_ROW = 0
  PB_COMPANY = 1
  PB_IS_SERVICE_BUREAU = 2
  PB_CLEANED_LINK = 3
  PB_ADDRESS = 4
  PB_COUNTRY_CODE = 5 

  #if ever use again, do more like castle - use Supplier create
  def printabase_csv_loader(url)
    
    CSV.new(open(url)).each do |row|
      if row[PB_USE_ROW] == "TRUE" and Supplier.find_by_name(row[PB_COMPANY].downcase).nil?
        
        s = Supplier.new
        s.name = row[PB_COMPANY]
        s.url_main = row[PB_CLEANED_LINK]
        s.name_for_link = Supplier.proper_name_for_link(s.name)
        if s.save
          puts "#{s.name} saved successfully."
        else
          puts "Error saving #{s.name}"
        end
        
        if !row[PB_ADDRESS].nil? and row[PB_ADDRESS].length > 0
          a = Address.new
          a.notes = row[PB_ADDRESS]
          a.place_id = s.id
          a.place_type = "Supplier"
          if a.save and s.create_or_update_address({country: row[PB_COUNTRY_CODE]}
)
            puts "#{s.name}'s address saved successfully."
          else
            puts "Error saving #{s.name}'s address"
          end
        end
        
      end
    end

  end

  CA_COMPANY = 0
  CA_LINK = 1
  CA_STATE = 2
  CA_TAGS = 3

  def castle_csv_loader(url)

    CSV.new(open(url)).each do |row|
      if !(row[CA_COMPANY].nil? or row[CA_COMPANY] == "" or row[CA_COMPANY] == "company")
        params = {}
        params[:name] = row[CA_COMPANY]
        params[:url_main] = row[CA_LINK]
        params[:source] = "crawler_castle"
        params[:name_for_link] = Supplier.proper_name_for_link(params[:name])

        s = Supplier.create(params)
        if s.id.present?
          s.create_or_update_address( country: "US",
                                      state: row[CA_STATE]
                                    )
          tag_ids = castle_tag_parser(row[CA_TAGS])
          if tag_ids.present?
            tag_ids.each do |tag_id|
              s.add_tag(tag_id)
            end
          end
          s.add_tag(Tag.find_by_name("datadump").id) #important to mark them as such
        end
      end
    end

    return true
  end

  def castle_tag_parser(tags)
    #starts as castle term : our term, for legibility. Then our term changed to tag_ids
    return nil unless tags.present?
    split = tags.split(" ")
    translator_input = { 
      "SLA" => "SLA",
      "FDM" => "FDM",
      "SLS" => "SLS",
      "Scanning" => "3d_scanning",
      "J-P" => "Polyjet",
      "3DP" => "ZPrinter",
      "EBM" => "EBM",
      "SLM" => "SLM",
      "Perfactory" => "Perfactory",
      "DOD" => "DOD"
    }
    translator = {}
    translator_input.map{ |k,v| translator[k] = Tag.find_by_name(v).id }
    in_progress = split.map{|t| translator[t]}
    answer = in_progress.reject{|t| t.nil?} #get rid of no-returns
    return answer
  end

  UTAH_COMPANY = 0
  UTAH_LINK = 1
  UTAH_POSSIBLE_STATE = 2

  def utah_csv_loader(url)

    CSV.new(open(url)).each do |row|
      if !(row[UTAH_COMPANY].nil? or row[UTAH_COMPANY] == "" or row[UTAH_COMPANY] == "company")
        params = {}
        params[:name] = row[UTAH_COMPANY]
        params[:url_main] = row[UTAH_LINK]
        params[:source] = "crawler_utah"
        params[:name_for_link] = Supplier.proper_name_for_link(params[:name])

        s = Supplier.create(params)
        if s.id.present?
          s.create_or_update_address( country: "US",
                                      state: Geography.transform(:short_name,row[UTAH_POSSIBLE_STATE],:long_name,"state")
                                    )
          s.add_tag(Tag.find_by_name("datadump").id) #important to mark them as such
        end
      end
    end
  end

end