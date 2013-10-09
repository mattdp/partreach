# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  family        :string(255)
#  note          :text
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  exclusive     :boolean          default(FALSE)
#  visible       :boolean          default(TRUE)
#  readable      :string(255)
#  name_for_link :string(255)
#

class Tag < ActiveRecord::Base

  has_many :combos
  has_many :suppliers, :through => :combos
 
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :readable, presence: true, uniqueness: {case_sensitive: false}
  validates :name_for_link, presence: true

  def self.tag_set(category,attribute)
    sets = {
      risky: %w(e0_out_of_business e1_existence_doubtful),
      network: %w(n6_signedAndNDAd n5_signed_only)
    }
    if attribute == :name
      return sets[category]
    elsif attribute == :id
      return sets[category].map { |n| Tag.find_by_name(n).id }
    elsif attribute == :object 
      return sets[category].map { |n| Tag.find_by_name(n) }
    else
      return "This should never happen"
    end
  end

  def self.proper_name_for_link(readable)
    Supplier.proper_name_for_link(readable)
  end

  def self.return_family_ids(family)
  	answer = []
  	Tag.find_each do |t|
  		answer << t.id if t.family == family
  	end
  	return answer
  end

  #return hash of {family1:[tag1,tag2],family2:[tag3:tag4]}
  def self.family_names_and_tags
    answers = {}
    Tag.find_each do |t|
      t.family.nil? ? tkey = "No family" : tkey = t.family
      if answers.has_key?(tkey)
        answers[tkey] << t
      else
        answers[tkey] = [t]
      end
    end
    return answers
  end

  #takes array of 1-n tags and a country
  def self.total_suppliers_tagged(tags, country = nil)
    counter = 0
    Supplier.find_each do |s|
      count_this = true
      if !country.nil?
        count_this = false if s.address.nil? or s.address.country != country
      end
      tags.each do |t|
        count_this = false unless s.has_tag?(t.id)
      end
      counter += 1 if count_this
    end
    return counter
  end

  def user_readable
    self.readable.nil? ? self.name : self.readable
  end

end
