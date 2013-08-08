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
#

class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :email_valid, :email_subscribed, :supplier_id
  has_secure_password

  has_many :orders, :dependent => :destroy
  has_many :dialogues, :through => :orders, :dependent => :destroy
  has_many :reviews
  has_one :address, :as => :place
  has_one :supplier

  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates :name, presence: true, length: { maximum: 20 }, uniqueness: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates	:email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  validates :supplier_id, uniqueness: true, allow_nil: true

  #can cause some serious overlap problems if abused
  def create_and_link_to_supplier(name,email,supplier_id)
    user = User.new
    user.name = name
    user.email = email
    user.supplier_id = supplier_id
    user.save(:validate => false)

    user.send_password_reset(supplier_id)
  end

  def send_password_reset(supplier_id=nil) #http://railscasts.com/episodes/274-remember-me-reset-password
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(:validate => false)
    if supplier_id.nil?
      UserMailer.password_reset(self).deliver
    else
      UserMailer.supplier_intro_email(self,supplier_id).deliver
    end
  end

  def self.can_use_email?(email_address)
    object = User.find_by_email(email_address)
    object = Lead.find_by_email(email_address) if object.nil?
    return false if object.nil?
    return (object.email_valid and object.email_subscribed)
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
