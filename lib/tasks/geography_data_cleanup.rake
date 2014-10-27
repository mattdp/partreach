desc 'one-time data fixes for Geography'
task :geography_data_cleanup => :environment do

  # set short_name, long_name, and name_for_link for generic "unknown" state & country
  Geography.where(short_name: nil).each do |g|
    g.short_name = "unknown"
    g.long_name = "Unknown"
    g.name_for_link = Geography.proper_name_for_link("#{g.level}_unknown")
    g.save
  end  

  # merge where short_name is empty string
  Geography.where(short_name: '').each do |from|
    to = Geography.where(short_name: 'unknown', level: from.level).first
    Address.geo_merge_and_destroy(from.id, to.id)
  end

  # merge alternate geographies
  Geography.where(short_name: 'us', level: 'country').each do |from|
    to = Geography.where(short_name: 'US', level: 'country').first
    Address.geo_merge_and_destroy(from.id, to.id)
  end
  Geography.where(short_name: 'United States', level: 'country').each do |from|
    to = Geography.where(short_name: 'US', level: 'country').first
    Address.geo_merge_and_destroy(from.id, to.id)
  end
  Geography.where(short_name: 'united Kingdom', level: 'country').each do |from|
    to = Geography.where(short_name: 'United Kingdom', level: 'country').first
    Address.geo_merge_and_destroy(from.id, to.id)
  end

  # batch update name_for_link
  Geography.where(name_for_link: nil).each do |g|
    g.long_name = g.short_name unless g.long_name
    g.name_for_link = Geography.proper_name_for_link("#{g.level}_#{g.short_name}") unless g.name_for_link
    g.save
  end

end

