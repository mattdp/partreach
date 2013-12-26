require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

desc 'Set up order groups'
task :order_group_setup
	Order.find_each do |order|
		Group.create({name: "Default", order_id: order.id}) if OrderGroup.find_by_order_id.nil?
	end
end


desc 'Set all externals to have Supplier type and same id. One-time migration'
task :set_externals_to_consumer => :environment do
	External.find_each do |external|
		external.consumer_id = external.supplier_id
		external.consumer_type = "Supplier"
		external.save
	end
end

desc 'Use country and state information for addresses to point to or create Geos'
task :point_addresses_to_geographies => :environment do
	Address.find_each do |address|
		[:country,:state].each do |attribute|
			geo = Geography.create_or_reference_geography(address.attributes[attribute.to_s],:short_name,attribute.to_s)
			address.send("#{attribute}_id=",geo.id)
			address.save
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