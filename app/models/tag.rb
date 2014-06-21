# == Schema Information
#
# Table name: tags
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  family        :string(255)
#  note          :text
#  created_at    :datetime
#  updated_at    :datetime
#  exclusive     :boolean          default(FALSE)
#  visible       :boolean          default(TRUE)
#  readable      :string(255)
#  name_for_link :string(255)
#

class Tag < ActiveRecord::Base

  belongs_to :tag_group
  has_many :combos
  has_many :suppliers, :through => :combos
 
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :readable, presence: true, uniqueness: {case_sensitive: false}
  validates :name_for_link, presence: true
  validates_presence_of :tag_group

  def self.all_by_group
    Tag.includes(:tag_group).order('tag_groups.id, tags.id')
  end

  def self.tag_set(category,attribute)
    sets = {
      risky: %w(e0_out_of_business e1_existence_doubtful),
      network: %w(n6_signedAndNDAd n5_signed_only),
      new_supplier: %w(b0_none_sent n1_no_contact e2_existence_unknown)
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

  #return hash of {group1_name=>[tag1, tag2, ...], group2_name=>[tag3, tag4, ...], ...}
  def self.tags_by_group
    answers = {}
    TagGroup.eager_load(:tags).each do |tag_group|
      answers[tag_group.group_name] = tag_group.tags
    end
    answers
  end

  #takes array of 1-n tags and a country
  def self.total_suppliers_tagged(tags, country = nil)
    counter = 0
    Supplier.find_each do |s|
      count_this = true
      if !country.nil?
        count_this = false if s.address.nil? or s.address.country.short_name != country
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

  def self.proper_name_for_link(name)
    Supplier.proper_name_for_link(name)
  end

end
