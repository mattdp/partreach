class TagRelationshipType < ActiveRecord::Base
  belongs_to :source_group, :class_name => 'TagGroup' 
  belongs_to :related_group, :class_name => 'TagGroup'
end
