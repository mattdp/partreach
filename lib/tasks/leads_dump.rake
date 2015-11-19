require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

#name, company, orders, emails, ID
desc 'output CSV of leads and relevant data'
task :leads_dump => :environment do
  output_string = "First Name,Last Name,Full Name,Company,Orders,Email,ID\n"
  Lead.find_each do |lead|
    lc = lead.lead_contact
    next if lc.blank?
    line = "#{lc.first_name},"
    line += "#{lc.last_name},"
    line += "#{lc.full_name_untrusted},"
    line += "#{lc.company},"
    line += (lead.user.present? ? "#{lead.user.orders.count}," : "0,")
    line += "#{lc.email},"
    line += "#{lead.id}"
    output_string += "#{line}\n"
  end
  puts output_string
end