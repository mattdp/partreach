class TagRelationship < ActiveRecord::Base
  belongs_to :source_tag, class_name: 'Tag'
  belongs_to :relationship, foreign_key: "tag_relationship_type_id", class_name: 'TagRelationshipType'
  belongs_to :related_tag, class_name: 'Tag'
end
