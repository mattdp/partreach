class TagGroup < ActiveRecord::Base
  has_many :tags
  has_many :taggable_types
end
