class TagRelationship < ActiveRecord::Base
  belongs_to :source_tag, :class_name => 'Tag'
  belongs_to :related_tag, :class_name => 'Tag'
end
