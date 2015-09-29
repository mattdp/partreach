# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  admin                  :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  address_id             :integer
#  password_digest        :string(255)
#  remember_token         :string(255)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  examiner               :boolean          default(FALSE)
#  supplier_id            :integer
#  team_id                :integer
#

class User < ActiveRecord::Base
  has_secure_password

  has_many :orders, -> { order id: :desc }, :dependent => :destroy
  has_many :dialogues, :through => :orders, :dependent => :destroy
  has_many :reviews
  has_one :address, :as => :place, :dependent => :destroy
  belongs_to :supplier
  belongs_to :team
  has_one :lead, dependent: :destroy
  has_many :web_search_results, :foreign_key => "action_taken_by_id"
  has_many :comments
  has_many :comment_ratings

  before_save :create_remember_token

  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true
  validates :supplier_id, uniqueness: true, allow_nil: true

  #this does not track how many reminder emails, nor does it causally link reminders to filling things out
  def behaviors
    returnee = {}
    contact = self.lead.lead_contact
    
    returnee[:id] = self.id
    returnee[:name] = contact.full_name_untrusted
    returnee[:comments_filled_out] = Comment
      .where(user_id: self.id)
      .reject{|c| c.untouched?}
      .count    
    ids_of_reminded_comments = Event
      .where(model: "User", model_id: self.id)
      .where(happening: "sent_reminder_email")
      .map{|e| e.target_model_id}
      .uniq
    returnee[:comments_reminded_about] = ids_of_reminded_comments.count
    returnee[:comments_reminded_about_and_filled_out] = Comment
      .where(id: ids_of_reminded_comments)
      .reject{|c| c.untouched?}
      .count
    returnee[:total_pos] = PurchaseOrder.joins('INNER JOIN comments ON comments.purchase_order_id = purchase_orders.id')
      .where(comments: {user_id: self.id})
      .count
    returnee[:comments_with_two_or_less_stars] = Comment
      .where(user_id: self.id)
      .select{|c| c.overall_score.present? and c.overall_score > 0 and c.overall_score < 3}
      .count

    return returnee
  end

  #which providers not to ask a user about for X days
  def dont_ask_for_feedback(days_not_to_reask = 10)
    #find comments where user updated in last X days
    comments = Comment.where("updated_at >= ?",Date.today-days_not_to_reask.days)
      .where(user_id: self.id)
    #see if untouched; if so, get provider
    comments = comments.reject{|c| c.untouched?}
    return comments.map{|c| c.provider.name}.uniq
    #dedupe and return the names as array
  end

  def emailable_date
    email_happenings = ["sent_reminder_email"]
    events = Event.where(model_id: self.id)
      .where(model: "User")
      .where("happening IN (?)",email_happenings)
      .order("created_at")

    if events.present? and self.team.present?
      return (events.last.created_at + self.team.organization.default_reminder_days.days)
    else
      return Date.today
    end

  end

  def self.create_for_hax_v1_launch(team_name,email,first_name,last_name=nil)
    name = first_name
    name += " #{last_name}" if last_name

    u = User.create_with_dummy_password(name,email)
    u.password = "changemeplease"
    u.password_confirmation = "changemeplease"
    u.save
    contact = u.lead.lead_contact
    contact.first_name = first_name #first name only used on site to start
    contact.last_name = last_name
    contact.save

    t = Team.where("name = ?",team_name)
    if t.blank?
      t = Team.create(name: team_name)
    else
      t = t[0]
    end
    u.team_id = t.id
    u.save

    o = Organization.where("name = ?","HAX")
    if o.blank?
      o = Organization.create(name:"HAX") 
    else
      o = o[0]
    end

    t.organization = o
    t.save
  end

  def organization
    team.organization if team
  end

  def in_organization?
    organization.present?
  end

  def get_events
    Event.for_user(self).each do |event|
      p "#{event.created_at.strftime("%m/%d/%Y %H:%M")}: #{event.happening} #{event.target_model} #{event.target_model_id}"
    end
  end

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
