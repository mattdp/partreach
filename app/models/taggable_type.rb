# == Schema Information
#
# Table name: taggable_types
#
#  id           :integer          not null, primary key
#  type_name    :string(255)      not null
#  tag_group_id :integer          not null
#  created_at   :datetime
#  updated_at   :datetime
#

class TaggableType < ActiveRecord::Base
  belongs_to :tag_group
end
