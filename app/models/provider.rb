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
#  name_in_purchasing_system  :string(255)
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

  #depends on options existing
  def create_linked_po_and_comment!(options)
    warning_prefix = "***** "
    returner = {}
    returner[:output_string] = ""

    returner[:po] = PurchaseOrder.new({ provider: self, 
      description: options[:description],
      project_name: options[:project_name],
      id_in_purchasing_system: options[:id_in_purchasing_system],
      price: options[:price],
      quantity: options[:quantity],
      issue_date: options[:issue_date]
    })

    if !returner[:po].save
      returner[:output_string] += "#{warning_prefix}PO saving failure for row_identifier #{options[:row_identifier]}. Skipping.\n"
      return returner
    end

    returner[:comment] = Comment.new({ provider: self,
      user: options[:user],
      comment_type: "purchase_order",
      purchase_order: returner[:po]
    })

    if !returner[:comment].save
      returner[:output_string] += "#{warning_prefix}WARNING: ORPHAN PO. Comment saving failure for row_identifier #{options[:row_identifier]}.\n"
    else
      returner[:output_string] += "Success. Comment #{returner[:comment].id} created from row with SB ID #{options[:row_identifier]}.\n"
    end

    return returner
  end

  # creates external object and adds it to provider's collection of externals
  def add_external(original_filename, remote_file_name)
    externals.create!(url: '#', original_filename: original_filename, remote_file_name: remote_file_name)
  end

  def self.proper_name_for_link(name)
    return name.downcase.gsub(/\W+/, "")
  end

  def prepend_http_to_url
    if self.url_main.present?
      self.url_main = /^http/.match(self.url_main) ? self.url_main : "http://#{self.url_main}"
    end
  end

  def po_names_and_counts
    uids_and_counts = Comment.where("provider_id = ? and comment_type = 'purchase_order'",self.id)
      .group(:user_id).count.sort_by{|k,v| -v}
    answer = []
    #james, would love to talk with you about how to input array of user ids and get all their lead contacts in one operation
    uids_and_counts.each do |tuple|
      answer << [User.find(tuple[0]).lead.lead_contact,tuple[1]]
    end
    return answer
  end

  def self.safe_name_check(organization_id,name)
    return nil unless (name.present? and organization_id.present?)
    possible = Provider.where("name = ? and organization_id = ?",name,organization_id)
    possible = Provider.where("name_in_purchasing_system = ? and organization_id = ?",name,organization_id) unless possible.present?
    return nil unless possible.present?
    return possible[0]
  end

  def self.contact_fields
    fields = [
      [:contact_name, "Contact name"],
      [:contact_role, "Contact role"],
      [:contact_phone, "Phone"],
      [:contact_email, "Email"],
      [:contact_skype, "Skype"]
    ]
    return fields
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
