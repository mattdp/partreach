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
#  notes               :string(255)
#  currency            :string(255)      default("dollars")
#  recommended         :boolean          default(FALSE)
#

class Dialogue < ActiveRecord::Base
  attr_accessible :initial_select, :opener_sent, :response_received, :further_negotiation, :won, :order_id, :supplier_id, \
  :material, :process_name, :process_cost, :process_time, :shipping_name, :shipping_cost, :total_cost, :notes, :currency, :recommended

  belongs_to :order
  has_one :supplier
  has_one :user, :through => :order

end
