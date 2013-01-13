class Order < ActiveRecord::Base
  attr_accessible :quantity

  belongs_to :user
  has_many :dialogues, :dependent => :destroy

end
