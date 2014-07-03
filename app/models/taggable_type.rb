class TaggableType < ActiveRecord::Base
  belongs_to :tag_group
end
