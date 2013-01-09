class Supplier < ActiveRecord::Base
  attr_accessible :name, :url, :zipcode, :blurb

  has_many :dialogues
  has_one :address, :as => :place

end
