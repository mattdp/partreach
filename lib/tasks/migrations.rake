require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

desc 'Use country and state information for addresses to point to or create Geos'
task :swap_addresses_for_geographies => :environment do
	Address.find_each do |address|
		[:country,:state].each do |attribute|
			#look for create or locate, not sure what class it's in, model off that
			#set relevant pointer in address to the thing
		end
	end
end

desc 'One-time migration of machine/manufacturer to separate models'
task :migrate_machines => :environment do 
	Machine.find_each do |machine|
		manufacturer_name = machine.attributes["manufacturer"]
		mfg = Manufacturer.where("name = ?",manufacturer_name)
		if mfg.present?
			mfg = mfg[0]
		else
			mfg = Manufacturer.create({name: manufacturer_name})
		end
		machine.manufacturer_id = mfg.id
		machine.save
	end
end

desc 'Create sample suppliers for database'
task :populate_suppliers => :environment do
	require 'active_record/fixtures'

	ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "suppliers")
end