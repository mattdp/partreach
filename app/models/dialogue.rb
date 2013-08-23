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
#

class Dialogue < ActiveRecord::Base
  attr_accessible :initial_select, :opener_sent, :response_received, :further_negotiation, :won, :order_id, :supplier_id, \
  :material, :process_name, :process_cost, :process_time, :shipping_name, :shipping_cost, :total_cost, :notes, :currency, \
  :informed

  belongs_to :order
  has_one :supplier
  has_one :user, :through => :order

  def knows_outcome?
  	return (self.informed or self.declined? or self.won?)
  end

  def declined?
  	return (self.response_received and (self.total_cost.nil? or self.total_cost == 0))
  end

  def bid?
  	return (self.response_received and self.total_cost.present? and self.total_cost > 0)
  end

end
