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
#  readable   :string(255)
#

class Tag < ActiveRecord::Base
  attr_accessible :family, :name, :note, :exclusive, :visible, :readable

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

  #return hash of {family1:[tag1,tag2],family2:[tag3:tag4]}
  def self.family_names_and_tags
    answers = {}
    Tag.all.each do |t|
      t.family.nil? ? tkey = "No family" : tkey = t.family
      if answers.has_key?(tkey)
        answers[tkey] << t
      else
        answers[tkey] = [t]
      end
    end
    return answers
  end

  def user_readable
    self.readable.nil? ? self.name : self.readable
  end

end
