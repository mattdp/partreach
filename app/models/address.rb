# == Schema Information
#
# Table name: addresses
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  street     :string(255)
#  city       :string(255)
#  state      :string(255)
#  zip        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  place_id   :integer
#  place_type :string(255)
#

class Address < ActiveRecord::Base
  attr_accessible :city, :name, :state, :street, :zip

  belongs_to :place, :polymorphic => true

  validates :user_id, presence: true
end
