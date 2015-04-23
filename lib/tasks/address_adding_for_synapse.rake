desc 'one-time address adding for synapse'
task :address_adding_for_synapse => :environment do

  organization_id = Organization.find_by_name("Synapse").id
  providers = Provider.where("organization_id = ?",organization_id)
  providers.each do |p|
    options = Address.parse_string_into_options(p.location_string)
    Address.create_or_update_address(p,options)
  end

end