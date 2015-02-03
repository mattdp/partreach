require "open-uri"
#draws on supplier_csv_import.rake heavily
#current sheet: https://docs.google.com/a/supplybetter.com/spreadsheets/d/1B3PBeMXKGvT6lUuDdt5v7VrbxBKva0SAEcRgppDZqIc/edit#gid=469578003

desc 'import providers from csv'
task :supplier_csv_import => :environment do
  # expected field layout: website,name,email,phone,street_address,city,state,zip,country
  CSV.new(open(ENV['url']), headers: true).each do |row|
    puts "***** IMPORT DATA: #{row.to_csv}"

    provider_params = {}
    [:id_within_source,:flag,:verified,:name,:city,:url_main,:contact_phone,:contact_qq,:contact_email,:address].each do |attribute|
      provider_params[attribute] = row['"#{attribute.to_s}"'].strip if row['"#{attribute.to_s}"']
    end

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