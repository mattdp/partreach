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

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :name_for_link, presence: true, uniqueness: {case_sensitive: false}

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

    tags = Tag.distinct.joins(:taggings).where(taggings: {taggable_type: 'Provider'}).distinct
    tags = tags.sort_by{|t| t.name}

    tags.each do |tag|
      hash[tag] = Tagging.where("tag_id = ? and taggable_type = 'Provider'",tag.id).map{|tgg| tgg.taggable}.sort_by{|provider| provider.name}
    end

    return hash
  end

end
