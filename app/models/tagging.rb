# == Schema Information
#
# Table name: taggings
#
#  id                 :integer          not null, primary key
#  tag_id             :integer          not null
#  taggable_id        :integer          not null
#  taggable_type      :string(255)      not null
#  source             :string(255)
#  last_updated_by_id :integer
#  confidence         :integer
#  notes              :text
#  created_at         :datetime
#  updated_at         :datetime
#

class Tagging < ActiveRecord::Base
  belongs_to :tag, touch: true
  belongs_to :taggable, polymorphic: true
end
