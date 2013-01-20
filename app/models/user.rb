# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  admin      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  address_id :integer
#

class User < ActiveRecord::Base
  attr_accessible :admin, :email, :name

  has_many :orders, :dependent => :destroy
  has_many :dialogues, :through => :orders, :dependent => :destroy
  has_one :address, :as => :place

end
