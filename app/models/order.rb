# == Schema Information
#
# Table name: orders
#
#  id         :integer          not null, primary key
#  quantity   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Order < ActiveRecord::Base
  attr_accessible :quantity
  attr_readonly :id
  
  belongs_to :user
  has_many :dialogues, :dependent => :destroy

end
