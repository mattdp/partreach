# == Schema Information
#
# Table name: tag_relationships
#
#  id                       :integer          not null, primary key
#  source_tag_id            :integer          not null
#  related_tag_id           :integer          not null
#  created_at               :datetime
#  updated_at               :datetime
#  tag_relationship_type_id :integer          not null
#

class TagRelationship < ActiveRecord::Base
  belongs_to :source_tag, class_name: 'Tag'
  belongs_to :relationship, foreign_key: "tag_relationship_type_id", class_name: 'TagRelationshipType'
  belongs_to :related_tag, class_name: 'Tag'

  def readable
    "'#{source_tag.readable}' #{relationship.description} '#{related_tag.readable}'"
  end

  #doesn't seem to be working but possibly useful; reexamine as get more sophisticated
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
