# == Schema Information
#
# Table name: suppliers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  url_main      :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  blurb         :text
#  email         :string(255)
#  phone         :string(255)
#  address_id    :integer
#  url_materials :string(255)
#

class Supplier < ActiveRecord::Base
  attr_accessible :name, :url_main, :url_materials, :blurb, :email, :phone, :address_id, :category

  has_many :dialogues
  has_one :address, :as => :place

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  def self.return_category(category)
  	answer = []
  	Supplier.all.each do |s|
  		answer << s if s.category == category
  	end
  	return answer
  end

end

#may need to add material and method
