require "open-uri"
#draws on supplier_csv_import.rake heavily

desc 'import providers from csv'
task :supplier_csv_import => :environment do
  # expected field layout: website,name,email,phone,street_address,city,state,zip,country
  CSV.new(open(ENV['url']), headers: true).each do |row|
    puts "***** IMPORT DATA: #{row.to_csv}"

    provider_params = {}
    provider_params[:name] = row['name'].strip if row['name']
    #NEED TO ADD THE OTHER ATTRIBUTES HERE, OR MAYBE HAVE IT BE A LOOP ON SYMBOL NAME

    if provider_params[:id_within_source]
      existing_provider = Provider.where("id_within_source = ?",provider_params[:id_within_source])
    else
      existing_provider = nil
    end  

    begin
      if existing_provider.present?
        puts "***** FOUND EXISTING PROVIDER. ID: #{provider.id} NAME: #{provider.name}"
      else
        new_provider = Provider.new(provider_params)
        new_provider.name_for_link = Provider.proper_name_for_link(row['name'])

        new_provider.source = 'hax_sheet_import'

        new_provider.save!
        puts "***** ADDED PROVIDER: #{new_provider.name} (#{new_provider.id})"
      end
    rescue ActiveRecord::ActiveRecordError => e
      puts "***** ERROR attempting to add or update: #{e.message}"
    end
  end
end