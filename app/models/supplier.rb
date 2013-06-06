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
#  source        :string(255)
#

class Supplier < ActiveRecord::Base
  attr_accessible :name, :url_main, :url_materials, :blurb, :email, :phone, :address_id, :source

  has_many :dialogues
  has_one :address, :as => :place
  has_many :combos
  has_many :tags, :through => :combos

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  def has_tag?(tag_id)
    self.tags.include?(Tag.find(tag_id))
  end

end

#may need to add material and method
