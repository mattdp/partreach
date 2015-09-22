# == Schema Information
#
# Table name: tags
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  family          :string(255)
#  note            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  exclusive       :boolean          default(FALSE)
#  visible         :boolean          default(TRUE)
#  readable        :string(255)
#  name_for_link   :string(255)
#  tag_group_id    :integer
#  organization_id :integer
#

class Tag < ActiveRecord::Base

  belongs_to :tag_group
  belongs_to :organization
  has_many :taggings, dependent: :destroy
  has_many :suppliers, :through => :taggings, :source => :taggable, :source_type => 'Supplier'
  has_many :providers, :through => :taggings, :source => :taggable, :source_type => 'Provider'
  has_many :purchase_orders, :through => :taggings, :source => :taggable, :source_type => 'PurchaseOrder'
  has_many :tag_relationships, foreign_key: "source_tag_id", class_name: "TagRelationship", dependent: :destroy
  has_many :related_tags, :through => :tag_relationships
  has_many :reverse_tag_relationships, foreign_key: "related_tag_id", class_name: "TagRelationship"
  has_many :source_tags, :through => :reverse_tag_relationships
 
  validates :name, presence: true
  validates_uniqueness_of :name, scope: :organization_id
  validates :readable, presence: true
  validates :name_for_link, presence: true
  validates_presence_of :tag_group

  @@tag_sets = nil

  def self.search_list(sorted_tags_by_providers,id_only=false)
    sorted_tags_by_providers.each do |e|
      e[0] = "#{e[1].readable} (#{e[0]} #{"supplier".pluralize(e[0])})"
      if id_only
        e[1] = e[1].id
      else
        e[1] = "#{Organization.encode_search_string([e[1]])}"
      end
    end
  end

  #there will be something more sophisticated in the future, so not worrying about
  #sorting by relationship type yet
  def immediate_neighboring_tag_relationships(allow_tags_with_zero_results=false)
    sources = TagRelationship.where(source_tag_id: self.id)
    relateds = TagRelationship.where(related_tag_id: self.id)
    combined = sources + relateds
  end

  def immediate_neighboring_tag_ids
    relationships = self.immediate_neighboring_tag_relationships
    relationships.map{|r| r.source_tag_id == self.id ? r.related_tag_id : r.source_tag_id}.uniq
  end

  def relate(target_tag,relationship_name)
    return false unless self.organization_id == target_tag.organization_id
    tag_relationship_type = TagRelationshipType.where("name = ?",relationship_name)
    return false unless tag_relationship_type.present?
    tag_relationship_type = tag_relationship_type[0]
    exists_already = TagRelationship.where("source_tag_id = ? AND related_tag_id = ? AND 
      tag_relationship_type_id = ?", self.id, target_tag.id,
      tag_relationship_type.id)
    return exists_already[0] if exists_already.present?
    return TagRelationship.create(source_tag_id: self.id, 
      related_tag_id: target_tag.id, 
      tag_relationship_type_id: tag_relationship_type.id)
  end

  def self.initialize_tag_sets
    @@tag_sets = {}
    set_categories = {
      risky: %w(e0_out_of_business e1_existence_doubtful),
      network: %w(n6_signedAndNDAd n5_signed_only),
      new_supplier: %w(b0_none_sent n1_no_contact e2_existence_unknown),
      csv_import: %w(b0_none_sent n1_no_contact e3_existence_confirmed)
    }
    set_categories.each do |key, values|
      @@tag_sets[key] = {}
      @@tag_sets[key][:name] = values
      @@tag_sets[key][:id] = values.map { |tag_name| Tag.predefined(tag_name).id }
      @@tag_sets[key][:object] = values.map { |tag_name| Tag.predefined(tag_name) }
    end
  end

  #does not change name for link
  def change_name_and_readable(change_into_this)
    old_name = self.name
    old_readable = self.readable
    self.name = change_into_this
    self.readable = change_into_this
    if self.save
      puts "Name/readable both changed (from #{old_name}/#{old_readable}) to #{change_into_this}"
    else
      puts "FAILURE changing #{old_name}/#{old_readable} to #{change_into_this}. Are you sure those names aren't taken?"
    end
  end

  def self.tag_set(category,attribute)
    Tag.initialize_tag_sets unless @@tag_sets
    @@tag_sets[category][attribute]
  end

  def self.predefined(name)
    Tag.where(name: name).where(organization_id: nil).first
  end

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

  #return hash of {group1_name=>[tag1, tag2, ...], group2_name=>[tag3, tag4, ...], ...}
  def self.tags_by_group
    answers = {}
    TagGroup.eager_load(:tags).each do |tag_group|
      answers[tag_group.group_name] = tag_group.tags
    end
    answers
  end

  def self.by_taggable_type(type)
    Tag.joins(:taggings).where(taggings: {taggable_type: type}).distinct.order(:readable)
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

  def assimilate(old_tag)
    if old_tag.organization == organization
      Tagging.connection.exec_query(
        "delete from taggings where id in
         (select old.id from taggings old 
          inner join taggings new on old.taggable_id=new.taggable_id and old.taggable_type=new.taggable_type 
          where old.tag_id=#{old_tag.id} and new.tag_id=#{self.id})"
      )
      Tagging.where(tag_id: old_tag.id).update_all(tag_id: self.id)
      
      TagRelationship.where(source_tag_id: old_tag.id).update_all(source_tag_id: self.id)
      TagRelationship.where(source_tag_id: old_tag.id).update_all(related_tag_id: self.id)
      
      self.update_attribute(:note, old_tag.note) unless note.present?

      old_tag.delete # NOT #destroy -- don't want to perform validations, cascade deletes, etc.

      Event.add_event("Tag", id, "merged tag '#{old_tag.readable}' (id=#{old_tag.id}) into '#{readable}' (id=#{id})")
    else
      Event.add_event("Tag", id, "unable to merge tags belonging to different organizations '#{old_tag.readable}' (id=#{old_tag.id}) into '#{readable}' (id=#{id})")
    end
  end

  def assimilate_list(old_tag_id_array)
    old_tag_id_array.each do |tag_id|
      self.assimilate(Tag.find(tag_id))
    end
  end

end
