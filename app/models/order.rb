# == Schema Information
#
# Table name: orders
#
#  id                   :integer          not null, primary key
#  quantity             :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#  drawing_file_name    :string(255)
#  drawing_content_type :string(255)
#  drawing_file_size    :integer
#  drawing_updated_at   :datetime
#  name                 :string(255)
#  deadline             :date
#  supplier_message     :text
#  recommendation       :text
#  material_message     :text
#  next_steps           :text
#  suggested_suppliers  :text
#  drawing_units        :string(255)
#  status               :string(255)      default("Needs work")
#

class Order < ActiveRecord::Base
  attr_accessible :quantity, :drawing, :name, :deadline, :supplier_message, \
  :material_message, :next_steps, :suggested_suppliers, :drawing_units, :status
  has_attached_file :drawing,
  									:url => "/:attachment/:id/:style/:basename.:extension",
  									:path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
  
  belongs_to :user
  has_many :dialogues, dependent: :destroy

  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :user_id, presence: {message: "needs a name, valid email, and >= 6 character password"}
  validates :material_message, presence: true, length: {minimum: 2}
  validates :drawing_units, presence: true, length: {minimum: 1}

  def finished?
    status = self.status
    return true if Order.order_status_hash[status]
    self.dialogues.each do |d|
      return true if d.won
    end
    return false #0 dialogue, multiple unwon dialogues, and is_over nil cases
  end

  def self.rfqs_order
    finished = [] 
    unfinished = []

    orders = Order.all.sort
    orders.each do |a|
      a.finished? ? finished << a : unfinished << a
    end
    return unfinished.concat(finished)
  end

  #{selected not opened, opened not responded, responded not informed, informed}
  def analytics_count
    dialogues = self.dialogues
    answer = {
      "selected_not_opened" => dialogues.map{|x| !(x.opener_sent or x.response_received) }.count(true),
      "opened_not_responded" => dialogues.map{|x| x.opener_sent and !(x.response_received) }.count(true),
      "responded_not_informed" => dialogues.map{|x| x.response_received and !(x.knows_outcome?) }.count(true),
      "informed" => dialogues.map{|x| x.knows_outcome? }.count(true)
    }
    return answer
  end

  def visible_dialogues
    visibles = []
    self.dialogues.map{|d| visibles << d if d.opener_sent}
    return visibles
  end

  #status, order completed
  ORDER_STATUS_HASH = {
    "Needs work" => false,
    "Waiting for supplier" => false,
    "Waiting for buyer" => false,
    "Finished - closed" => true,
    "Finished - no close" => true
  }

  def self.order_status_hash
    return ORDER_STATUS_HASH
  end

end
