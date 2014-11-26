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
  accepts_nested_attributes_for :external, reject_if: :all_blank
  belongs_to :order_group
  has_one :order, through: :order_group

  validates :name, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :material, length: { minimum: 2 }

  # def self.create_with_external(order_group_id, filename, url)
  #   part = Part.create!({order_group_id: order_group_id, name: filename})
  #   external = External.create!({url: url, consumer_id: part.id, consumer_type: "Part" }) if part
  # end

end
