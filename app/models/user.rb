# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  admin                  :boolean          default(FALSE)
#  created_at             :datetime
#  updated_at             :datetime
#  address_id             :integer
#  password_digest        :string(255)
#  remember_token         :string(255)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  examiner               :boolean          default(FALSE)
#  supplier_id            :integer
#

class User < ActiveRecord::Base
  has_secure_password

  has_many :orders, :dependent => :destroy
  has_many :dialogues, :through => :orders, :dependent => :destroy
  has_many :reviews
  has_one :address, :as => :place, :dependent => :destroy
  has_one :supplier
  has_one :lead, dependent: :destroy
  has_many :web_search_results, :foreign_key => "action_taken_by_id"

  before_save :create_remember_token

  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  validates :supplier_id, uniqueness: true, allow_nil: true

  #can cause some serious overlap problems if abused
  def self.create_and_link_to_supplier(name,email,supplier_id)
    user = User.create_with_dummy_password(name,email)

    supplier = Supplier.find(supplier_id)
    supplier.claim_profile(user.id)
    supplier.add_communication("create_and_link_to_supplier")

    user.send_supplier_intro_email(supplier_id)
  end

  def self.create_and_send_password_reset(name,email)
    user = User.create_with_dummy_password(name,email)
    user.send_password_reset
  end

  def self.create_with_dummy_password(name,email,admin=false)
    user = User.new
    user.password_digest = SecureRandom.urlsafe_base64 #have something in there so it can save
    user.admin = admin
    user.save(validate: false)
    Lead.create_or_update_lead({
      lead: {user_id: user.id},
      lead_contact: { name: name, email: email}
    })
    return user
  end

  def send_password_reset #http://railscasts.com/episodes/274-remember-me-reset-password
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    self.save!(validate: false)
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

  def create_or_update_address(options=nil)
    Address.create_or_update_address(self,options)
  end 

  def self.admins
    User.select{|u| u.admin}
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
