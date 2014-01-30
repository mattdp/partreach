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
#  email_snippet          :text
#

require 'csv'

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
      tq = parts.inject(0) {|sum,part| sum + part.quantity}
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
    dialogues = self.dialogues.select{|d| d.total_cost and d.total_cost > 0}
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

def add_complex_order(location)

    order = self
    if order.nil?
      puts "Order not found. Exiting."
      return false
    end

    cols = {
      part_bom_identifier: 0,
      order_group_name: 1,
      part_name: 2,
      part_quantity: 3,
      drawing_link: 4,
      drawing_units: 5
    }

    counter = 1
    success_counter = 0

    CSV.new(open(location)).each do |row|
      if counter > 1

        order = Order.find(self.id) #need to renew each time since order.order_groups doesn't otherwise update

        row_output = "Row #{row}"
        
        order_group = order.order_groups.detect{|og| og.name == row[cols[:order_group_name]]}
        binding.pry
        next unless order_group = add_complex_order_helper("OrderGroup",order_group,\
          "OrderGroup.create({name: '#{row[cols[:order_group_name]]}',\
                              order_id: '#{order.id}'}\
                            )")

        parts = order_group.parts
        part = parts.detect{|part| part.name == row[cols[:part_name]]}
        next unless part = add_complex_order_helper("Part",part,\
          "Part.create({name: '#{row[cols[:part_name]]}',\
                        quantity: '#{row[cols[:part_quantity]]}',\
                        bom_identifier: '#{row[cols[:part_bom_identifier]]}',\
                        order_group_id: '#{order_group.id}'\
                      })")

        external = part.external
        next unless external = add_complex_order_helper("External",external,\
          "External.create({url: '#{row[cols[:drawing_link]]}',\
                            units: '#{row[cols[:drawing_units]]}',\
                            consumer_id: '#{part.id}',\
                            consumer_type: 'Part'\
                          })")
        success_counter += 1
      end
      counter += 1
    end
    #counter-2: -1 for index start 1 and -1 for title row.
    puts "Adding of complex order attempted. #{success_counter} of #{counter-2} rows OK."
    return true
  end

  #pass in what should be variable if it exists already
  #return variable or nil (if should go to next)
  def add_complex_order_helper(model_name,variable,create_code)
    if variable.nil?
      variable = eval(create_code)
      if variable
        print ". New #{model_name} created: '#{variable.id}'"
      else
        print "FAILED to create #{model_name}. Aborting row."
        return false
      end
    else
      print "#{model_name} exists"
    end
    return variable
  end

  def email_snippet_generator
    snippet = 
      "<p>There is a SupplyBetter customer who has submitted an RFQ for the following project. If you are interested, please return a quote with the following:</p>
      <h3>What We Need</h3>
      <br>
      <p><strong>Total Cost</strong> (including any shipping and taxes):</p>"
    if self.priority == "cost"
      snippet += "<p><strong>Estimated delivery date:</strong></p><p><strong>Deadline for client to place order to hit that delivery date:</strong></p>"
    else
      snippet += "<p><strong>Lead Time:</strong></p>"
    end
    snippet += "<h3>Project Details</h3><br>\n"

    snippet += "<p><strong>Priority:</strong> "
    case self.priority
    when "cost"
      snippet += "Cost is the main concern here. This is not a rush order.</p>"
    when "quality"
      snippet += "Quality is the main concern here with this project. See the note from client for details on what exactly they're looking for.</p>"
    else
      snippet += "</p>"
    end
    
    snippet += "<p><strong>Deadline:</strong> "
    if self.priority == "cost"
      snippet += "ASAP. Client is willing to pay rush order costs to hit a deadline of #{self.deadline}, see note below.</p>"
    else
      snippet += "#{self.deadline}</p>\n" if self.deadline.present?
    end

    snippet += "
      <p><strong>Shipping Zipcode:</strong> #{self.user.address.zip}</p>

      <p><strong>Infill:</strong></p>

      <p><strong>Build Orientation:</strong></p>

      <p><strong>Note from Client:</strong> #{self.supplier_message}</p>

      <p><strong>Notes about Client:</strong></p>"

    return snippet
  end

end
