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
  has_one :order, through: :order_group

  validates :quantity, presence: true, numericality: true

end
