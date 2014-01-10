# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  admin                  :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  address_id             :integer
#  password_digest        :string(255)
#  remember_token         :string(255)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  email_valid            :boolean          default(TRUE)
#  email_subscribed       :boolean          default(TRUE)
#  examiner               :boolean          default(FALSE)
#  supplier_id            :integer
#  phone                  :string(255)
#

class User < ActiveRecord::Base
  has_secure_password

  has_many :orders, :dependent => :destroy
  has_many :dialogues, :through => :orders, :dependent => :destroy
  has_many :reviews
  has_one :address, :as => :place, :dependent => :destroy
  has_one :supplier
  has_one :lead

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates :name, presence: true, length: { maximum: 40 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates	:email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  validates :supplier_id, uniqueness: true, allow_nil: true

  #can cause some serious overlap problems if abused
  def self.create_and_link_to_supplier(name,email,supplier_id)
    user = User.new
    user.name = name
    user.email = email
    user.password_digest = SecureRandom.urlsafe_base64 #have something in there so it can save
    user.save(validate: false)
    user.auto_create_lead

    supplier = Supplier.find(supplier_id)
    supplier.claim_profile(user.id)
    supplier.add_communication("create_and_link_to_supplier")

    user.send_supplier_intro_email(supplier_id)
  end

  def send_password_reset #http://railscasts.com/episodes/274-remember-me-reset-password
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    self.save!(:validate => false)
    Event.add_event("User",self.id,"requested_password_reset")
    UserMailer.password_reset(self).deliver
  end

  def send_supplier_intro_email(supplier_id)
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    self.save!(:validate => false)
    Event.add_event("Supplier",self.id,"sent_account_intro_email")
    UserMailer.supplier_intro_email(self,Supplier.find(supplier_id)).deliver
  end

  #assumes object has email, email_valid, email_subscribed
  def self.can_use_email?(object)
    object.find_by_email(email_address)
    return false if object.nil?
    return (object.email_valid and object.email_subscribed)
  end

  def auto_create_lead
    lead = Lead.create({user_id: self.id, source: "auto_from_user_creation"})
    lc = LeadContact.create({contactable_id: lead.id, contactable_type: "Lead"})
    return (lead and lc)
  end

  #return array of emails
  #DOES NOT have unsubscriptions or false emails taken into account, nor does the system have them
  def self.emails_of_buyers_and_leads
    emails = []
    getter = Proc.new {|x| emails << x.email unless x.email.nil? or x.email == ""}
    User.all.map &getter
    Lead.all.map &getter
    return emails.uniq
  end 

  def create_or_update_address(options=nil)
    Address.create_or_update_address(self,options)
  end 

  private

    def generate_token(column) #http://railscasts.com/episodes/274-remember-me-reset-password
      begin
        self[column] = SecureRandom.urlsafe_base64
      end while User.exists?(column => self[column])
    end

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
