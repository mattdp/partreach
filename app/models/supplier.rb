# == Schema Information
#
# Table name: suppliers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  url        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  blurb      :text(255)
#  email      :string(255)
#  phone      :string(255)
#  address_id :integer
#

class Supplier < ActiveRecord::Base
  attr_accessible :name, :url, :blurb, :email, :phone, :address_id

  has_many :dialogues
  has_one :address, :as => :place

end

#may need to add material and method