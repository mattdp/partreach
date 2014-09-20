class TagRelationship < ActiveRecord::Base
  belongs_to :source_tag, class_name: 'Tag'
  belongs_to :relationship, foreign_key: "tag_relationship_type_id", class_name: 'TagRelationshipType'
  belongs_to :related_tag, class_name: 'Tag'

  def self.related_tags_by_relationship(source_tag_id)
    relationships_hash = {}

    tag_relationships =
      TagRelationship.where(source_tag_id: source_tag_id).
      includes(:relationship).references(:relationship).
      includes(:related_tag).references(:related_tag)

    tag_relationships.each do |tr|
      if relationships_hash[tr.relationship.name]
        relationships_hash[tr.relationship.name] << tr.related_tag
      else
        relationships_hash[tr.relationship.name] = [tr.related_tag]
      end
    end

    relationships_hash
  end

end
