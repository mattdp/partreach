# == Schema Information
#
# Table name: providers
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  url_main                   :string(255)
#  source                     :string(255)      default("manual")
#  name_for_link              :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  contact_qq                 :string(255)
#  contact_wechat             :string(255)
#  contact_phone              :string(255)
#  contact_email              :string(255)
#  contact_name               :string(255)
#  contact_role               :string(255)
#  verified                   :boolean          default(FALSE)
#  city                       :string(255)
#  location_string            :text
#  id_within_source           :integer
#  contact_skype              :string(255)
#  organization_id            :integer          not null
#  organization_private_notes :text
#  external_notes             :text
#  import_warnings            :text
#  supplybetter_private_notes :text
#

class Provider < ActiveRecord::Base

  before_save :prepend_http_to_url

  has_many :comments
  has_many :purchase_orders
  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings
  has_many :externals, :as => :consumer, :dependent => :destroy
  has_one :address, :as => :place, :dependent => :destroy
  belongs_to :organization

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates :name_for_link, presence: true, uniqueness: {case_sensitive: false}
  validates :organization, presence: true

  #code for secure pictures, while WIP
  def self.sandbox
    #hitting the token vending service
    sts = Aws::STS::Client.new(
      region: "us-east-1",
      access_key_id: ENV['SB_CLIENTS_SYNAPSE_ACCESS_KEY'],
      secret_access_key: ENV['SB_CLIENTS_SYNAPSE_SECRET_KEY']
      )
    #getting a temporary session token
    token = sts.get_session_token(
      duration_seconds: 15*60 #minimum 15m
      )
    #setting up credentials for S3 with that token
    credentials = Aws::Credentials.new(
      token[:credentials][:access_key_id], 
      token[:credentials][:secret_access_key],
      token[:credentials][:session_token]
      )
    #s3 api hitter
    s3 = Aws::S3::Client.new(
      region: 'us-east-1',
      credentials: credentials
      )

    #should succeed - YES
    object = s3.get_object(
      bucket: "sb-clientfiles-synapse",
      key: "sizes.jpg"
      )

    #should fail - YES
    no_permissions_object = s3.get_object(
      bucket: "private-for-testing-security",
      key: "sizes.jpg"
    )
  end

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

  #needs to return 0-5 inclusive integer
  def average_score
    numbers_without_zeros = self.comments.map{|comment| comment.overall_score}.reject{|n| n==0}
    return 0 if numbers_without_zeros == []
    preround = numbers_without_zeros.inject(:+)/numbers_without_zeros.count.to_f
    return preround.round
  end

  #returns nil or a parsed date string
  def latest_purchase_order_date
    return nil if !self.purchase_orders.present?
    po = PurchaseOrder.where("provider_id = ?",self.id).order("created_at DESC").first
    return po.created_at.strftime("%b %e, %Y")
  end

  def index_address
    address = self.address
    return nil if address.nil?
    returnee = "#{address.city}"
    if address.country.present? and !(address.country.short_name == "US" or address.country.short_name == "unknown")
      returnee.present? ? returnee += ", #{address.country.short_name}" : returnee = "#{address.country.short_name}"
    elsif address.state.present? and !(address.state.short_name == "unknown")
      returnee.present? ? returnee += ", #{address.state.short_name}" : returnee = "#{address.state.short_name}"
    end
    return returnee
  end

  #modified from supplier version - MAKE SURE TO LOOK AT ORGANIZATION TAG METHODS FIRST
  #this isn't good with tag groups
  def add_tag(tag_id)
    tag = Tag.find_by_id(tag_id)
    return false if tags.include?(tag)
    tags << tag
    return true
  end

#---
# TAG STUFF COPIED FROM SUPPLIER DIRECTLY - MAKE SURE TO LOOK AT ORGANIZATION TAG METHODS FIRST
# this isn't good with tag groups
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
