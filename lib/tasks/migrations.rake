require "#{Rails.root}/lib/RakeHelper.rb"
include RakeHelper

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