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
    order_group = self.order_group
    supplier = self.supplier
    contact = supplier.rfq_contact

    returnee = {}
    returnee[:subject] = "SupplyBetter RFQ ##{order.id}1 for #{supplier.name}"

    contact.first_name.present? ? returnee[:body] = "<p>Hi #{@contact.first_name},</p>" : returnee[:body] = "<p>Hi there,</p>"

    returnee[:body] += order.email_snippet_generator
    returnee[:body] += order_group.email_snippet_generator

    returnee[:body] += "<p>As always, feel free to let me know if you have any questions, and thank you for looking into this project.</p>"

    return returnee
  end

end
