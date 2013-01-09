class Address < ActiveRecord::Base
  attr_accessible :city, :name, :state, :street, :zip
end
