# == Schema Information
#
# Table name: tag_groups
#
#  id         :integer          not null, primary key
#  group_name :string(255)      not null
#  exclusive  :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class TagGroup < ActiveRecord::Base
  has_many :tags
  has_many :taggable_types
  has_many :source_tag_relationship_types, foreign_key: "source_group_id", class_name: "TagRelationshipType"
  has_many :related_tag_relationship_types, foreign_key: "related_group_id", class_name: "TagRelationshipType"
end
