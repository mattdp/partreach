class Supplier < ActiveRecord::Base
  attr_accessible :name, :url, :zipcode, :blurb
end
