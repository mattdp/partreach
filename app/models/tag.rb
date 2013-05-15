# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  family     :string(255)
#  note       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Tag < ActiveRecord::Base
  attr_accessible :family, :name, :note

  has_many :combos
  has_many :suppliers, :through => :combos
 
end
