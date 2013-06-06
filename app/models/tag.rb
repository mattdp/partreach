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
#  exclusive  :boolean          default(FALSE)
#  visible    :boolean          default(TRUE)
#

class Tag < ActiveRecord::Base
  attr_accessible :family, :name, :note, :exclusive, :visible

  has_many :combos
  has_many :suppliers, :through => :combos
 
  validates :name, presence: true, uniqueness: {case_sensitive: false}

  def self.return_family_ids(family)
  	answer = []
  	Tag.all.each do |t|
  		answer << t.id if t.family == family
  	end
  	return answer
  end

end
