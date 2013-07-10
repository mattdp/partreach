#should refactor so has set of primary tag to be invoked if a secondary is present
desc 'add dependant tags to all suppliers automatically'
task :tag_tree => :environment do

	automatics = {
		"3d_printing" => ["SLS","FDM","SLA","Polyjet","ZPrinter","metal_printing","DMLS","FFF"],
		"custom_machining" => ["5_axis_machining"],
		"metal_printing" => ["DMLS"]
	}

	automatics.keys.each do |k|
		primary = Tag.find_by_name(k).id
		secondaries = automatics[k].map { |t| t = Tag.find_by_name(t).id }

		Supplier.all.each do |s|
			if !s.has_tag?(primary) #ok that this falses a lot, though could be more efficient
				s.tags.each do |t|
					s.add_tag(primary) if secondaries.include? t.id
				end
			end
		end

	end

end

desc 'Setup URL names for suppliers'
task :supplier_url_creation => :environment do
	Supplier.all.each do |s|
		s.name_for_link = s.name.downcase.gsub(/\s+/, "")
		s.save
	end
end

desc 'Create sample suppliers for database'
task :populate_suppliers => :environment do
	require 'active_record/fixtures'

	ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "suppliers")
end