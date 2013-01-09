class User < ActiveRecord::Base
  attr_accessible :admin, :email, :name

  has_many :orders, :dependent => :destroy
  has_many :dialogues, :through => :orders, :dependent => :destroy
  has_one :address, :as => :place

end
