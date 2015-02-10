require "open-uri"
#draws on supplier_csv_import.rake heavily
#current sheet: https://docs.google.com/a/supplybetter.com/spreadsheets/d/1B3PBeMXKGvT6lUuDdt5v7VrbxBKva0SAEcRgppDZqIc/edit#gid=469578003

desc 'import hax people from csv'
task :hax_people_csv_import => :environment do

  CSV.new(open(ENV['datafile'])).each do |row|
    puts "***** IMPORT DATA: #{row.to_csv}"

    begin
      User.create_for_hax_v1_launch(row[0],row[3],row[1],row[2])
    rescue ActiveRecord::ActiveRecordError => e
      puts "***** ERROR attempting to add or update: #{e.message}"
    end
  end

end
