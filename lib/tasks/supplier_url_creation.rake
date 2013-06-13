desc 'Setup URL names for suppliers'
task :supplier_url_creation => :environment do
	Supplier.all.each do |s|
		s.name_for_link = s.name.downcase.gsub(/\s+/, "")
		s.save
	end
end