class Address < ActiveRecord::Base
  attr_accessible :city, :name, :state, :street, :zip

  belongs_to :place, :polymorphic => true
end
