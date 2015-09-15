# == Schema Information
#
# Table name: tag_relationship_types
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  source_group_id  :integer
#  related_group_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#  description      :string(255)
#

class TagRelationshipType < ActiveRecord::Base
  belongs_to :source_group, :class_name => 'TagGroup'
  belongs_to :related_group, :class_name => 'TagGroup'
  has_many :tag_relationships
end
