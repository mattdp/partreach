require 'csv'

desc "load pairs of related tags"
# fields: source_tag,relationship_type,related_tag
# assumes associated tag_relationship_types and their associated tag_groups already exist
task :load_related_tags => :environment do
  headers = [:source_tag, :relationship_type, :related_tag]
  CSV.new(open(ENV["url"]), {headers: headers}).each do |row|
    puts "ADDING: #{row[:source_tag]} #{row[:relationship_type]} #{row[:related_tag]}"
    relationship_type = TagRelationshipType.find_by_name(row[:relationship_type])
    source_tag = Tag.find_or_create!(row[:source_tag], relationship_type.source_group)
    related_tag = Tag.find_or_create!(row[:related_tag], relationship_type.related_group)
    add_tag_relationship(source_tag, relationship_type, related_tag)
  end
end

def add_tag_relationship(source_tag, relationship_type, related_tag)
  source_ok = valid_tag_group?(source_tag, relationship_type.source_group)
  related_ok = valid_tag_group?(related_tag, relationship_type.related_group)
  if source_ok && related_ok
    TagRelationship.create(
      source_tag: source_tag,
      relationship: relationship_type,
      related_tag: related_tag)
  end
end

def valid_tag_group?(tag, relationship_type_group)
  valid = (tag.tag_group == relationship_type_group)
  unless valid
    puts "ERROR: <#{tag.name}> does not belong to a valid group for specified relationship type"
  end
  return valid
end

desc "add lifecycle and machine tag_groups"
task :add_tag_groups => :environment do
  TagGroup.create(group_name: "lifecycle")
  TagGroup.create(group_name: "machine")
end

desc "add initial set of tag_relationship_types"
# assumes associated source_group and related_group already exist
task :add_tag_relationship_types => :environment do
  process_group = TagGroup.find_by(group_name: "process")
  lifecycle_group = TagGroup.find_by(group_name: "lifecycle")
  material_group = TagGroup.find_by(group_name: "material")
  machine_group = TagGroup.find_by(group_name: "machine")

  TagRelationshipType.create(source_group: process_group, name: "has subprocess", related_group: process_group)
  TagRelationshipType.create(source_group: process_group, name: "can be used for", related_group: lifecycle_group)
  TagRelationshipType.create(source_group: process_group, name: "requires process", related_group: process_group)
  TagRelationshipType.create(source_group: process_group, name: "requires material", related_group: material_group)
  TagRelationshipType.create(source_group: process_group, name: "can process", related_group: material_group)
  TagRelationshipType.create(source_group: process_group, name: "uses", related_group: machine_group)
  TagRelationshipType.create(source_group: material_group, name: "includes", related_group: material_group)
end