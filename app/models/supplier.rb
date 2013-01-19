class Supplier < ActiveRecord::Base
  attr_accessible :name, :url, :blurb, :email, :phone, :address_id

  has_many :dialogues
  has_one :address, :as => :place

end
