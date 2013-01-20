class Order < ActiveRecord::Base
  attr_accessible :quantity
  attr_readonly :id
  
  belongs_to :user
  has_many :dialogues, :dependent => :destroy

end
