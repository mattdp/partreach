desc 'check for suppliers with no existence tag'
task :check_existence_tag => :environment do
  existence_tags = Tag.joins(:tag_group).where(tag_groups: {group_name: 'existence'})
  Supplier.eager_load(:tags).each do |s|
    found = s.tags & existence_tags
    if found.empty?
      p "***** EXISTENCE TAG MISSING FOR: #{s.name} (#{s.id})"
    end
  end
end

desc 'add e2_existence_unknown to suppliers with no existence tag'
task :add_existence_unknown_tag => :environment do
  existence_tags = Tag.joins(:tag_group).where(tag_groups: {group_name: 'existence'})
  existence_unknown_tag_id = Tag.predefined('e2_existence_unknown').id
  count = 0
  Supplier.eager_load(:tags).each do |s|
    if (s.tags & existence_tags).empty?
      p "***** ADDING EXISTENCE UNKNOWN TAG FOR: #{s.name} (#{s.id})"
      s.add_tag(existence_unknown_tag_id)
      count += 1
    end
  end
  puts "#{count} tags added"
end
