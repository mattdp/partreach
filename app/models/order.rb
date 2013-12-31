# == Schema Information
#
# Table name: orders
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :integer
#  drawing_content_type   :string(255)
#  drawing_file_size      :integer
#  drawing_updated_at     :datetime
#  name                   :string(255)
#  deadline               :string(255)
#  supplier_message       :text
#  recommendation         :text
#  material_message       :text
#  next_steps             :text
#  suggested_suppliers    :text
#  status                 :string(255)      default("Needs work")
#  next_action_date       :string(255)
#  stated_experience      :string(255)
#  stated_priority        :string(255)
#  stated_manufacturing   :string(255)
#  notes                  :text
#  override_average_value :decimal(, )
#  columns_shown          :string(255)      default("all")
#

class Order < ActiveRecord::Base
  has_attached_file :drawing,
  									:url => "/:attachment/:id/:style/:basename.:extension",
  									:path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
  
  belongs_to :user
  has_many :order_groups, dependent: :destroy
  has_many :dialogues, through: :order_groups, dependent: :destroy
  has_many :parts, through: :order_groups, dependent: :destroy

  validates :user_id, presence: {message: "needs a name, valid email, and >= 6 character password"}
  validates :material_message, presence: true, length: {minimum: 2}
  validates :columns_shown, presence: true

  def total_quantity
    tq = 0
    if parts = self.parts
      tq = parts.inject(0) {|sum,part| part.quantity}
    end
    return tq
  end

  def finished?
    if Order.order_status_hash[self.status]
      return true 
    else
      return false
    end
  end

  def self.incomplete_orders
    incompletes = []
    Order.find_each do |o|
      incompletes << o if !o.finished?
    end
    return incompletes
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

  def quote_value
    qv = 0 # if no recommendations, quotes, or overrides
    dialogues = Dialogue.where("order_id = ? and total_cost > 0",self.id)
    if self.override_average_value
      qv = self.override_average_value #override in order for jobs where something was weird    
    elsif (dialogues.present? and recs = dialogues.select{|d| d.recommended} and recs.present?)
      values = recs.map{|d| d.total_cost}
      qv = values.sum / values.size.to_f
    elsif dialogues.present? #should this be a median?
      values = dialogues.map{|d| d.total_cost}
      qv = values.sum / values.size.to_f
    end
    return qv
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
    "Need to inform suppliers" => false,
    "Finished - closed" => true,
    "Finished - no close" => true
  }

  def self.order_status_hash
    return ORDER_STATUS_HASH
  end

  # return{supplier1.name => [order1.id, order2.id, order3.id], ...}
  def self.need_to_inform_suppliers_structure
    answer = {} 
    orders = Order.where("status = ?",'Need to inform suppliers')
    return answer unless orders.present?
    orders.each do |o|
      o.dialogues.each do |d|
        if d.should_be_informed?
          supplier = Supplier.find(d.supplier_id)
          if answer[supplier.id].present?
            answer[supplier.id] << o.id
          else
            answer[supplier.id] = [o.id]
          end
        end
      end
    end
    return answer
  end

end
