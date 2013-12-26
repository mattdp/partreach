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

require 'spec_helper'

describe "Dialogue" do
	it "should not allow two dialogues on the same order with the same supplier"
end
