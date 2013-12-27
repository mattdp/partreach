require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

desc 'Migrate order information to parts and externals. Doesn\'t assume part or external exists. Assumes one order group/order'
task :order_to_parts => :environment do 
	OrderGroup.find_each do |order_group|
		order = order_group.order

		part = order_group.parts
		if part == []
			part = Part.new({order_group_id: order_group.id})
			part.save validate: false
		else
			part = part[0]
		end

		external = part.external
		#current problem line
		external = External.new({consumer_id: part.id, consumer_type: "Part"}) if external.nil?

		external.url = order.drawing_file_name
		external.units = order.drawing_units
		part.quantity = order.quantity

		part_save = part.save
		external_save = external.save
		order_save = order.save
		success = (part_save and external_save and order_save)

		if success
			puts "Order #{order.id} transferred successfully"
		else
			puts "Order #{order.id} DID NOT TRANSFER SUCCESSFULLY. Part: #{part_save} External: #{external_save} Order: #{order_save}"
		end

	end
end

desc 'Set up order groups'
task :order_group_setup => :environment do
	Order.find_each do |order|
		OrderGroup.create({name: "Default", order_id: order.id}) if OrderGroup.find_by_order_id(order.id).nil?
	end

	Dialogue.find_each do |dialogue|
		dialogue.order_group_id = OrderGroup.find_by_order_id(dialogue.order_id).id
		dialogue.save
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