# == Schema Information
#
# Table name: providers
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  url_main         :string(255)
#  source           :string(255)      default("manual")
#  name_for_link    :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  contact_qq       :string(255)
#  contact_wechat   :string(255)
#  contact_phone    :string(255)
#  contact_email    :string(255)
#  contact_name     :string(255)
#  contact_role     :string(255)
#  verified         :boolean          default(FALSE)
#  city             :string(255)
#  address          :text
#  id_within_source :integer
#  contact_skype    :string(255)
#

class Provider < ActiveRecord::Base

  before_save :prepend_http_to_url

  has_many :comments
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :externals, :as => :consumer, :dependent => :destroy

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :name_for_link, presence: true, uniqueness: {case_sensitive: false}

  def add_external(url, filename)
    externals.create!(url: url, original_filename: filename)
  end

  def self.proper_name_for_link(name)
    return name.downcase.gsub(/\W+/, "")
  end

  def prepend_http_to_url
    if self.url_main.present?
      self.url_main = /^http/.match(self.url_main) ? self.url_main : "http://#{self.url_main}"
    end
  end

  def self.providers_hash_by_process
    hash = {}

    tags = Tag.by_taggable_type('Provider')

    tags.each do |tag|
      hash[tag] = Tagging.where("tag_id = ? and taggable_type = 'Provider'",tag.id).map{|tgg| tgg.taggable}.sort_by{|provider| provider.name}
    end

    return hash
  end

  #needs to return 0-5 inclusive integer
  def average_score
    numbers_without_zeros = self.comments.map{|comment| comment.overall_score}.reject{|n| n==0}
    return 0 if numbers_without_zeros == []
    preround = numbers_without_zeros.inject(:+)/numbers_without_zeros.count.to_f
    return preround.round
  end

  #user facing, for hax for now
  def tag_creator(tags,user_id=nil)
    tags.each do |tag_name|
      if tag_name.blank?
        next
      elsif Tag.where("name = ?",tag_name).present?
        tag = Tag.where("name = ?",tag_name)[0]
        self.add_tag(tag.id)
        Event.add_event("User","#{user_id}","attempted to add an existing tag","Tag",tag.id)
      elsif Tag.where("name_for_link = ?",Tag.proper_name_for_link(tag_name)).present?
        tag = Tag.where("name_for_link = ?",Tag.proper_name_for_link(tag_name))[0]
        self.add_tag(tag.id)
        Event.add_event("User","#{user_id}","attempted to add an existing tag","Tag",tag.id)
      else
        t = Tag.create(name: tag_name, readable: tag_name, name_for_link: Tag.proper_name_for_link(tag_name), tag_group_id: TagGroup.find_by_group_name("provider type").id)
        self.add_tag(t.id)
        Event.add_event("User","#{user_id}","added a new tag")
      end
    end
    return true
  end

  #modified from supplier version
  def add_tag(tag_id)
    tag = Tag.find_by_id(tag_id)
    return false if self.tags.include?(tag)
    self.tags << tag
    return true
  end

#---
# TAG STUFF COPIED FROM SUPPLIER DIRECTLY
#---

  def remove_tags(tag_id)
    self.tags.destroy(tag_id)
  end

  def has_tag?(tag_id)
    tags = taggings.map {|tg| tg.tag_id}
    tags.include? tag_id
  end

  def update_tags(submitted_tag_ids)
    saved_ok = true
    
    if(submitted_tag_ids and submitted_tag_ids.size > 0)

      current_tag_ids = self.tags.map{|t| "#{t.id}"}
      add_tag_ids = []
      remove_tag_ids = []

      submitted_tag_ids.map{|t| add_tag_ids << t if !t.in?(current_tag_ids)}
      current_tag_ids.map{|t| remove_tag_ids << t if !t.in?(submitted_tag_ids)}

      if add_tag_ids.size > 0
        add_tag_ids.each do |id|
          saved_ok = false unless self.add_tag(id)
        end
      end

      if remove_tag_ids.size > 0
        remove_tag_ids.each do |id|
          saved_ok = false unless self.remove_tags(id)
        end
      end
    end

    return saved_ok
  end  

end
