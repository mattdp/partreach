# == Schema Information
#
# Table name: orders
#
#  id         :integer          not null, primary key
#  quantity   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Order < ActiveRecord::Base
  attr_accessible :quantity, :drawing
  has_attached_file :drawing
  
  belongs_to :user
  has_many :dialogues, dependent: :destroy

  validates :quantity, presence: true, numericality: {greater_than: 0}
  #validates_attachment :drawing, attachment_presence: true, attachment_size: {less_than: 50.megabytes}
  validates :user_id, presence: true
end
