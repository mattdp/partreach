# == Schema Information
#
# Table name: externals
#
#  id            :integer          not null, primary key
#  url           :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  consumer_id   :integer
#  consumer_type :string(255)
#

class External < ActiveRecord::Base
  belongs_to :consumer, polymorphic: true

  validates :consumer_id, presence: true
  validates :consumer_type, presence: true
  validates :url, presence: true, uniqueness: { case_sensitive: false } 
  validates_uniqueness_of :url, scope: :supplier_id
end
