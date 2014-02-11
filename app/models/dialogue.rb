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
      supplier.remove_tags(Tag.find_by_name('b0_none_sent'))
    end
    if self.won
      tag_deal ||= Tag.find_by_name('b3_at_least_one_deal')
      supplier.add_tag(tag_deal.id)
    end
    if self.response_received
      tag_deal ||= Tag.find_by_name('b3_at_least_one_deal')
      supplier.add_tag(Tag.find_by_name('b2_quoted_no_deal').id) unless supplier.has_tag?(tag_deal.id)

      tag_oob ||= Tag.find_by_name('e0_out_of_business')
      supplier.add_tag(Tag.find_by_name('e3_existence_confirmed').id) unless supplier.has_tag?(tag_oob.id)
    end
  end

  #return array of hashes, each containing the needed information on suppliers, for caching purposes
  def self.dialogues_new_setup
    structure = []
    suppliers = Supplier.all.sort_by! { |s| s.name.downcase }
    suppliers.each do |supplier|
      address = supplier.address
      structure << {
        supplier: supplier,
        tag_names: supplier.tags.map{|t| t.name},
        safe_country: supplier.safe_country,
        safe_state: supplier.safe_state,
        safe_zip: supplier.safe_zip
      }
    end
    return structure
  end

  #return {subject, body} of email. subject is text, body is html
  def initial_email_generator
    order = self.order
    supplier = self.supplier
    contact = supplier.rfq_contact

    returnee = {}
    returnee[:subject] = "SupplyBetter RFQ ##{order.id}1 for #{supplier.name}"

    contact.first_name.present? ? returnee[:body] = "<p>Hi #{contact.first_name},</p>" : returnee[:body] = "<p>Hi there,</p>"

    returnee[:body] += order.email_snippet if order.email_snippet.present?

    parts_information = ""
    order.dialogues.select{|d| d.supplier_id == supplier.id}.each do |dialogue|
      parts_information += dialogue.order_group.email_snippet if dialogue.order_group.email_snippet.present?
    end

    returnee[:body] = returnee[:body].sub(Order.group_text_substitution,parts_information)

    #in paid network
    if (supplier.has_tag?(Tag.find_by_name('n5_signed_only').id) or supplier.has_tag?(Tag.find_by_name('n6_signedAndNDAd').id))
      returnee[:body] += "<p>You're a SupplyBetter network member, and we work to bring you buyers that fit your goals. If you choose to bid, SupplyBetter will invoice you for 1% of the quote value. We will pass this bid along to the customer, and if they select you, we'll put you directly in touch so you can take conversation from there.</p>"
    #probably doesn't know what we do
    elsif !(supplier.has_tag?(Tag.find_by_name('b2_quoted_no_deal').id) or supplier.has_tag?(Tag.find_by_name('b3_at_least_one_deal').id))
      returnee[:body] += "<p>Your company, #{supplier.name}, was a match for a SupplyBetter customer searching for manufacturing services. Please let me know if you would like to learn more about <a href='supplybetter.com'>SupplyBetter</a> or how this process works.</p>"
    end
      
    returnee[:body] += 
      "<p>As always, feel free to let me know if you have any questions, and thank you for looking into this project.</p>
      <p>Cheers,</p>
      <p>Rob</p>"

    return returnee
  end

  def generic_quote_ended_email_generator
    order = self.order
    supplier = self.supplier
    contact = supplier.rfq_contact

    returnee = {}
    returnee[:subject] = "SupplyBetter RFQ ##{order.id}1 for #{supplier.name}"

    contact.first_name.present? ? returnee[:body] = "<p>Hi #{contact.first_name},</p>" : returnee[:body] = "<p>Hi,</p>"

    returnee[:body] += "<p>Just following up to let you know the bidding for this project is closed. The client has chosen a quote from a different supplier. I appreciate your looking into this project and look forward to sending you business again.</p>"
    returnee[:body] += "<p>Best,</p>"
    returnee[:body] += "<p>Rob</p>"

    return returnee
  end

  def send_initial_email
    SupplierMailer.initial_supplier_email(self)
    self.update_attributes({initial_select: true, opener_sent: true})  
  end

  def send_generic_quote_ended_email
    SupplierMailer.generic_quote_ended_email(self)
    self.update_attributes({informed: true})
  end
  
end
