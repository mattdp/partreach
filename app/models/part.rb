# == Schema Information
#
# Table name: parts
#
#  id             :integer          not null, primary key
#  order_group_id :integer
#  quantity       :integer
#  name           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Part < ActiveRecord::Base

  has_one :external, :as => :consumer, :dependent => :destroy
  belongs_to :order_group

  validates :name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0}

end
