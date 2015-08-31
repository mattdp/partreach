# == Schema Information
#
# Table name: dialogues
#
#  id                  :integer          not null, primary key
#  initial_select      :boolean
#  opener_sent         :boolean
#  response_received   :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  supplier_id         :integer
#  further_negotiation :boolean
#  won                 :boolean
#  material            :string(255)
#  process_name        :string(255)
#  process_cost        :decimal(10, 2)
#  process_time        :string(255)
#  shipping_name       :string(255)
#  shipping_cost       :decimal(10, 2)
#  total_cost          :decimal(10, 2)
#  notes               :text
#  currency            :string(255)      default("dollars")
#  recommended         :boolean          default(FALSE)
#  informed            :boolean
#  internal_notes      :text
#  order_group_id      :integer
#  supplier_working    :boolean
#  email_snippet       :text
#  close_email_body    :text
#  billable            :boolean          default(FALSE)
#  past_experience     :string(255)
#

class Dialogue < ActiveRecord::Base

  belongs_to :order_group
  has_one :order, through: :order_group
  belongs_to :supplier
  has_one :user, :through => :order

  validates :supplier_id, :presence => true
  validates :order_group_id, :presence => true

  def knows_outcome?
    return (self.informed or self.declined? or self.won?)
  end

  def declined?
    return (self.response_received and (self.total_cost.nil? or self.total_cost == 0))
  end

  def bid?
    return (self.response_received and self.total_cost.present? and self.total_cost > 0)
  end

  def should_be_informed?
    return (self.opener_sent and !self.knows_outcome?)
  end

  def autotagger
    supplier = self.supplier
    if self.opener_sent
      supplier.remove_tags(Tag.predefined('b0_none_sent'))
    end
    if self.won
      tag_deal ||= Tag.predefined('b3_at_least_one_deal')
      supplier.add_tag(tag_deal.id)
    end
    if self.response_received
      tag_deal ||= Tag.predefined('b3_at_least_one_deal')
      supplier.add_tag(Tag.predefined('b2_quoted_no_deal').id) unless supplier.has_tag?(tag_deal.id)

      tag_oob ||= Tag.predefined('e0_out_of_business')
      supplier.add_tag(Tag.predefined('e3_existence_confirmed').id) unless supplier.has_tag?(tag_oob.id)
    end
  end

  #return {subject, body} of email. subject is text, body is html
  def initial_email_generator
    order = self.order
    supplier = self.supplier
    contact = supplier.rfq_contact

    returnee = {}
    returnee[:subject] = "SupplyBetter RFQ ##{order.id}1 for #{supplier.name}"

    contact.first_name.present? ? returnee[:body] = "<p>Hi #{contact.first_name},</p>" : returnee[:body] = "<p>Hi there,</p>"

    if self.email_snippet.present?
      returnee[:body] += "#{self.email_snippet}<p>If you are interested, please return a quote with the following:</p>" 
    else
      returnee[:body] += "<p>There is a SupplyBetter customer who has submitted an RFQ for the following project. If you are interested, please return a quote with the following:</p>"
    end
    
    returnee[:body] += order.email_snippet if order.email_snippet.present?

    # add in parts and images snippets for the appropriate order groups
    parts_information = ""
    images_information = ""
    order.dialogues.select{|d| d.supplier_id == supplier.id}.each do |dialogue|
      parts_information += dialogue.order_group.parts_snippet if dialogue.order_group.parts_snippet.present?
      images_information += dialogue.order_group.images_snippet if dialogue.order_group.images_snippet.present?
    end
    returnee[:body] = returnee[:body].sub(Order::PARTS_SNIPPETS_PLACEHOLDER, parts_information)
    returnee[:body] = returnee[:body].sub(Order::IMAGES_SNIPPETS_PLACEHOLDER, images_information)

    #in paid network
    if (supplier.has_tag?(Tag.predefined('n5_signed_only').id) or supplier.has_tag?(Tag.predefined('n6_signedAndNDAd').id))
      returnee[:body] += "<p>You're a SupplyBetter network member, and we work to bring you buyers that fit your goals. If you choose to bid, SupplyBetter will invoice you for 1% of the quote value. We will pass this bid along to the customer, and if they select you, we'll put you directly in touch so you can take conversation from there.</p>"
    #probably doesn't know what we do
    elsif !(supplier.has_tag?(Tag.predefined('b2_quoted_no_deal').id) or supplier.has_tag?(Tag.predefined('b3_at_least_one_deal').id))
      returnee[:body] += "<p>Your company, #{supplier.name}, was a match for a SupplyBetter customer searching for manufacturing services. Please let me know if you would like to learn more about <a href='http://www.supplybetter.com'>SupplyBetter</a> or how this process works.</p>"
    end
      
    returnee[:body] += 
      "<p>As always, feel free to let me know if you have any questions, and thank you for looking into this project.</p>
      <p>Cheers,</p>
      <p>Robert Martinez<br>Co-Founder & VP Eng.<br><a href='http://www.supplybetter.com'>SupplyBetter</a><br>W: 5022766224</p>"

    return returnee
  end

  def send_initial_email
    SupplierMailer.initial_supplier_email(self)
    self.update_attributes({initial_select: true, opener_sent: true})  
  end

  def send_rfq_close_email
    SupplierMailer.rfq_close_email(self)
    update(informed: true)
  end

  def self.billable_by_supplier(closed_orders)
    in_network_tags = Tag.tag_set(:network,:id)
    closed_order_ids = closed_orders.map {|o| o.id}
    result_hash = {}
    Dialogue.where(billable: true).
      includes(:supplier).references(:supplier).
      joins(supplier: :tags).where(tags: {id: in_network_tags}).
      joins(:order).where(orders: {id: closed_order_ids}).
      order('suppliers.id').
      each do |dialogue|
        if result_hash[dialogue.supplier]
          result_hash[dialogue.supplier] << dialogue
        else
          result_hash[dialogue.supplier] = [dialogue]
      end
    end
    result_hash
  end

  # 1% of sum of total cost of all billable bids during period
  def self.total_billable_fees(closed_orders)
    total = BigDecimal.new(0)
    Dialogue.billable_by_supplier(closed_orders).each do |supplier, dialogues|
      dialogues.each do |dialogue|
        total += dialogue.total_cost
      end
    end
    (total * Supplier::DEFAULT_BID_FEE).round(2)
  end

  def self.bid_summary_by_supplier(start_date, end_date)
    order_closed_events = Event.order_closed_events(start_date, end_date)
    closed_order_ids = order_closed_events.map { |e| e.model_id }
    order_closed_dates = {}
    order_closed_events.each do |event|
      order_closed_dates[event.model_id] = event.created_at
    end

    in_network_tags = Tag.tag_set(:network,:id)

    billable_bids =
     Dialogue.where(billable: true).
     includes(:supplier).references(:supplier).
     joins(supplier: :tags).where(tags: {id: in_network_tags}).
     joins(:order).where(orders: {id: closed_order_ids}).includes(:order)

    result_hash = {}
    billable_bids.each do |dialogue|
        bid_info = { dialogue: dialogue}
        bid_info[:order_close_date] = order_closed_dates[dialogue.order.id]
        if result_hash[dialogue.supplier]
          result_hash[dialogue.supplier] << bid_info
        else
          result_hash[dialogue.supplier] = [bid_info]
      end
    end
    result_hash
  end

end
