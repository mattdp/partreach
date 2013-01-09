class Dialogue < ActiveRecord::Base
  attr_accessible :initial_select, :opener_sent, :response_received
end
