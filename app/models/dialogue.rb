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
#  order_id            :integer
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

  belongs_to :order
  has_one :supplier
  has_one :user, :through => :order

  validates :supplier_id, :presence => true
  validates :order_id, :presence => true

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

end
