class Dialogue < ActiveRecord::Base
  attr_accessible :initial_select, :opener_sent, :response_received

  belongs_to :order
  has_one :supplier
  has_one :user, :through => :order

end
