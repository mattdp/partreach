require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

#name, company, orders, emails, ID
desc 'output CSV of leads and relevant data'
task :leads_dump => :environment do
  output_string = "Name,Company,Orders,Email,ID\n"
  Lead.find_each do |lead|
    line = ""
    line +=
    line +=
    line +=
    line +=
    line +=
    output_string += "#{line}\n"
  end
end