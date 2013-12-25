# == Schema Information
#
# Table name: externals
#
#  id            :integer          not null, primary key
#  supplier_id   :integer
#  url           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  consumer_id   :integer
#  consumer_type :string(255)
#

class External < ActiveRecord::Base
  has_one :supplier

  validates :supplier_id, presence: true
  validates :url, presence: true, uniqueness: { case_sensitive: false } 
  validates_uniqueness_of :url, scope: :supplier_id
end
