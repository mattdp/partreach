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
#  bom_identifier :string(255)
#

class Part < ActiveRecord::Base

  has_one :external, :as => :consumer, :dependent => :destroy
  accepts_nested_attributes_for :external
  belongs_to :order_group
  has_one :order, through: :order_group

end
