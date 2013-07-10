#desc 'add 3dp tag to all suppliers with related tags'
task :tag_threedee => :environment do
	Supplier.all.each do |s|

		threedee_tag = Tag.find_by_name("3d_printing").id

		subtags = [
			Tag.find_by_name("SLS").id,
			Tag.find_by_name("FDM").id,
			Tag.find_by_name("SLA").id,
			Tag.find_by_name("Polyjet").id,
			Tag.find_by_name("ZPrinter").id,
			Tag.find_by_name("metal_printing").id,
			Tag.find_by_name("DMLS").id,
			Tag.find_by_name("FFF").id
		]

		#ok that this falses a lot, though could be more efficient
		if !s.has_tag?(threedee_tag)
			s.tags.each do |t|
				s.add_tag(threedee_tag) if subtags.include? t.id
			end
		end

	end
end

#desc 'Setup URL names for suppliers'
task :supplier_url_creation => :environment do
	Supplier.all.each do |s|
		s.name_for_link = s.name.downcase.gsub(/\s+/, "")
		s.save
	end
end

#desc 'Create sample ssuppliers for database'
task :populate_suppliers => :environment do
	require 'active_record/fixtures'

	ActiveRecord::Fixtures.create_fixtures("#{Rails.root}/test/fixtures", "suppliers")
end