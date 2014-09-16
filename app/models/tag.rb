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
  has_many :taggings
  has_many :suppliers, :through => :taggings, :source => :taggable, :source_type => 'Supplier'
  has_many :tag_relationships, foreign_key: "source_tag_id", class_name: "TagRelationship"
  has_many :related_tags, :through => :tag_relationships
  has_many :reverse_tag_relationships, foreign_key: "related_tag_id", class_name: "TagRelationship"
  has_many :source_tags, :through => :reverse_tag_relationships
 
  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :readable, presence: true, uniqueness: {case_sensitive: false}
  validates :name_for_link, presence: true
  validates_presence_of :tag_group

  def self.find_or_create!(name, tag_group)
    tag = Tag.where("LOWER(readable) = ?", name.downcase).first
    unless tag
      tag = Tag.create!(
        name: name,
        readable: name,
        name_for_link: Tag.proper_name_for_link(name),
        tag_group: tag_group)
    end
    tag
  end

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

  def self.proper_name_for_link(name)
    Supplier.proper_name_for_link(name)
  end

  def user_readable
    self.readable.nil? ? self.name : self.readable
  end

  def eat(tag)
    unless self.note.present?
      self.note = tag.note 
      self.save
    end
    TagRelationship.where('source_tag_id = ?',tag.id).each do |tr|
      tr.update_column('source_tag_id', self.id) if TagRelationship.where(source_tag_id: self.id, related_tag_id: tr.related_tag_id).empty?
    end
    TagRelationship.where('related_tag_id = ?',tag.id).each do |tr|
      tr.update_column('related_tag_id', self.id) if TagRelationship.where(source_tag_id: tr.source_tag_id, related_tag_id: self.id).empty?
    end
    Tagging.where('tag_id = ?', tag.id).update_all(tag_id: self.id)
    tag.destroy
  end

  # Recursively get all the related_tags (descendants) of a tag
  def descendants(node = self, nodes = [])
    # THIS METHOD CURRENTLY IMPLIES THAT ONLY PARENT-CHILD RELATIONSHIPS EXIST
    # JAMES AND I ARE GOING TO DISCUSS TAGGING RELATIONSHIPS FURTHER
    if !node.related_tags.empty?
      node.related_tags.each {|n| nodes << n }
      node.related_tags.each {|n| n.descendants(n, nodes)}
    end
    nodes
  end

  # Recursively get all the related_tags (descendants) of a tag
  def ancestors(node = self, nodes = [])
    # THIS METHOD CURRENTLY IMPLIES THAT ONLY PARENT-CHILD RELATIONSHIPS EXIST
    # JAMES AND I ARE GOING TO DISCUSS TAGGING RELATIONSHIPS FURTHER
    if !node.source_tags.empty?
      node.source_tags.each {|n| nodes << n }
      node.source_tags.each {|n| n.ancestors(n, nodes)}
    end
    nodes
  end
end
