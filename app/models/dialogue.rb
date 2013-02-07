# == Schema Information
#
# Table name: dialogues
#
#  id                :integer          not null, primary key
#  initial_select    :boolean
#  opener_sent       :boolean
#  response_received :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  order_id          :integer
#  supplier_id       :integer
#  bid               :integer
#

class Dialogue < ActiveRecord::Base
  attr_accessible :initial_select, :opener_sent, :response_received, :further_negotiation, :won, :bid, :order_id, :supplier_id

  belongs_to :order
  has_one :supplier
  has_one :user, :through => :order

end
