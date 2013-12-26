# == Schema Information
#
# Table name: order_groups
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class OrderGroup < ActiveRecord::Base

	belongs_to :order
	has_many :parts
	has_many :dialogues

  validates :name, presence: true

end
