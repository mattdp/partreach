require "open-uri"
#draws on supplier_csv_import.rake heavily
#current sheet: https://docs.google.com/a/supplybetter.com/spreadsheets/d/1B3PBeMXKGvT6lUuDdt5v7VrbxBKva0SAEcRgppDZqIc/edit#gid=469578003

desc 'import providers from csv'
task :provider_csv_import => :environment do

  c = Contact.where("email = ?","peter@fakeemailforsetup.com")
  if c.present?
    u = c.contactable.user
  else
    u = User.create_for_hax_v1_launch("HAX","peter@fakeemailforsetup.com","Peter",last_name=nil)
  end

  CSV.new(open(ENV['datafile']), {headers: true, col_sep: "\t"}).each do |row|
    puts "***** IMPORT DATA: #{row.to_csv}"

    provider_params = {}
    [:id_within_source,:verified,:name,:city,:url_main,:contact_phone,:contact_qq,:contact_email,:address].each do |attribute|
      provider_params[attribute] = row["#{attribute.to_s}"].strip if row["#{attribute.to_s}"]
    end

    if provider_params[:id_within_source]
      existing_provider = Provider.where("id_within_source = ?",provider_params[:id_within_source])
    else
      existing_provider = nil
    end  

    begin
      if existing_provider.present? and false
        puts "***** FOUND EXISTING PROVIDER. ID WITHIN SOURCE: #{existing_provider[0].id_within_source} NAME: #{existing_provider[0].name}"
      elsif not(row['name'].present? and row['url_main'].present? and row['tag'].present?)
        puts "***** SKIPPING, LACKS NAME OR LACKS URL."        
      else
        new_provider = Provider.new(provider_params)
        new_provider.name_for_link = Provider.proper_name_for_link(row['name'])
        new_provider.tag_laser_cutting = true if row['flag'] == "laser_cutting"
        new_provider.tag_cnc_machining = true if row['flag'] == "cnc_machining"

        new_provider.source = 'hax_sheet_import'

        new_provider.save!
        puts "***** ADDED PROVIDER: #{new_provider.name} (#{new_provider.id})"

        Tagging.create(taggable_id: new_provider.id, taggable_type: "Provider", tag_id: Tag.find_by_name(row['tag'])) 

        if row['peter_comment'].present?
          Comment.create(provider: new_provider, user: u, payload: row['peter_comment'])
        end

      end
    rescue ActiveRecord::ActiveRecordError => e
      puts "***** ERROR attempting to add or update: #{e.message}"
    end
  end
end