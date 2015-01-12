# == Schema Information
#
# Table name: orders
#
#  id                     :integer          not null, primary key
#  created_at             :datetime
#  updated_at             :datetime
#  user_id                :integer
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
#  stated_quantity        :integer
#  units                  :string(255)
#

require 'csv'

class Order < ActiveRecord::Base

  before_save :create_view_token

  belongs_to :user
  has_many :order_groups, -> { order(:created_at) }, dependent: :destroy
  accepts_nested_attributes_for :order_groups, reject_if: :all_blank
  has_many :dialogues, through: :order_groups, dependent: :destroy
  has_many :parts, through: :order_groups, dependent: :destroy
  has_many :externals, :as => :consumer, :dependent => :destroy

  validates :units, presence: true
  validates :columns_shown, presence: true
  validates :user, presence: true
  validates :order_groups, presence: true
  # validates :externals, presence: true

  PARTS_SNIPPETS_PLACEHOLDER = "<[$PARTS$]>"
  IMAGES_SNIPPETS_PLACEHOLDER = "<[$IMAGES$]>"

  def self.max_id
    Order.maximum(:id) || 0
  end

  def alphabetical_unique_supplier_names
    return self.dialogues.map{|d| d.supplier_id}.uniq.map{|id| Supplier.find(id).name}.sort
  end

  def total_quantity
    return self.stated_quantity if self.stated_quantity
    tq = 0
    if parts = self.parts.select{ |p| p.quantity.present? and p.quantity > 0 }
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

    if self.stated_priority == "speed"
      turnaround_snippet = <<-HTML
<p><strong>Estimated delivery date:</strong></p>
<p><strong>Deadline for client to place order to hit that delivery date:</strong></p>
      HTML
      deadline_text = <<-HTML
ASAP. Client is willing to pay rush order costs to hit a deadline of #{self.deadline}, see note below.
      HTML
    else
      turnaround_snippet = <<-HTML
<p><strong>Lead Time:</strong></p>
      HTML
      deadline_text = self.deadline ||= ""
    end

    #omits speed, since that's covered in other fields
    case self.stated_priority
    when "speed"
      priority_snippet = ""
    when "cost"
      priority_snippet = <<-HTML
<p><strong>Priority:</strong> Cost is the main concern here. This is not a rush order.</p>
    HTML
    when "quality"
      priority_snippet = <<-HTML
<p><strong>Priority:</strong> Quality is the main concern with this project. 
See the note from client for details on what exactly they're looking for.</p>
    HTML
    end

    zipcode = self.user.address.zip if self.user && self.user.address && self.user.address.zip

    snippet = <<-HTML
<u><h3>What We Need</h3></u>
<p><strong>Total Cost</strong> (including any shipping and taxes):</p>
#{turnaround_snippet}
<u><h3>Project Details</h3></u>

#{priority_snippet}
<p><strong>Deadline:</strong> #{deadline_text}</p>

#{Order::PARTS_SNIPPETS_PLACEHOLDER}

<p><strong>Shipping Zipcode:</strong> #{zipcode}</p>

<p><strong>Infill:</strong> </p>
<p><strong>Build Orientation:</strong> </p>
<p><strong>Note from Client:</strong><i> </i></p>
<p><strong>Notes about Client:</strong> </p>

#{Order::IMAGES_SNIPPETS_PLACEHOLDER}
    HTML

    if self.externals.present?
      order_id = self.id

      snippet += <<-HTML
---------- EXTERNALS ----------
      HTML

      self.externals.each do |external|
        suffix = external.url.split(".").last.upcase
        unless suffix.in? ["PNG", "JPG", "ZIP"]
          snippet += <<-HTML
(<a href="#{external.url}"><strong>Link to #{suffix} file</strong></a>)
          HTML
        end

        if suffix.in? ["PNG", "JPG"]
          snippet += <<-HTML
<p><a href="#{external.url}" alt="SupplyBetter RFQ#{order_id}" target="_blank">
<img src="#{external.url}" alt="SupplyBetter RFQ#{order_id}" width="460"></a></p>
          HTML
        end
      end
    end

    snippet
  end

  def self.metrics(interval,tracking_start_date)
    output = {}

    dates = Order.date_ranges(interval,tracking_start_date)

    output[:titles] = [interval.to_s, "RFQs Created", "RFQs Closed", "Total average quote value", "Total Billable Fees"]

    printout = []
    index = 0
    #-2 since using dates[index] and dates[index+1]
    while index <= dates.length - 2   
      created_orders = Order.created_orders(dates[index], dates[index+1])
      closed_orders = Order.closed_orders(dates[index], dates[index+1])
      total_average_quote_value = Order.total_average_quote_value(closed_orders)
      total_billable_fees = Dialogue.total_billable_fees(closed_orders)

      unit = []
      unit << dates[index]
      unit << created_orders.count
      unit << closed_orders.count
      unit << total_average_quote_value
      unit << total_billable_fees
      printout << unit
      index += 1
    end
    output[:printout] = printout.reverse

    return output
  end

  def self.created_orders(start_date, end_date)
    Order.where("created_at >= ? AND created_at < ?", start_date, end_date)
  end

  def self.closed_orders(start_date, end_date)
    order_closed_events = Event.order_closed_events(start_date, end_date)
    closed_order_ids = order_closed_events.map { |e| e.model_id }
    Order.where(id: closed_order_ids)
  end

  def self.total_average_quote_value(closed_orders)
    average_quote_values = closed_orders.map{ |o| o.quote_value }
    average_quote_values.sum
  end

  def quote_value
    # if order override (for jobs where something was weird)
    return override_average_value if self.override_average_value

    # all dialogues with quotes submitted for this order
    quotes = dialogues.select{|d| d.total_cost and d.total_cost > 0}

    # if no quotes submitted
    return BigDecimal.new(0) if quotes.empty?

    if ( (recs = quotes.select{|d| d.recommended}) && recs.present?)
      # recommended quote(s) 
      values = recs.map{ |d| d.total_cost }
    else
      # all quotes
      values = quotes.map{ |d| d.total_cost }
    end

    # average quote value
    (values.sum / values.size).round(2)
  end

  def self.date_ranges(interval,tracking_start_date) 

    if interval == :months
      #list of months, including one to two beyond the current one
      dates = ((tracking_start_date)..(Date.today+31)).map{|d| Date.new(d.year, d.month, 1) }.uniq
    elsif interval == :weeks
      while tracking_start_date < (Date.today + 7)
        dates << tracking_start_date
        tracking_start_date += 7
      end
    end

    return dates
  end

  def dialogue_partition
    partition = {}
    partition[:won] = dialogues.select{|d| d.won}
    partition[:placed_bid] = dialogues.select{|d| d.response_received and d.total_cost and d.total_cost > 0}
    partition[:no_response_or_refused] = dialogues.reject{|d| partition[:won].include?(d) or partition[:placed_bid].include?(d)}
    return partition
  end

  def create_view_token
    self.view_token = SecureRandom.hex
  end

end
