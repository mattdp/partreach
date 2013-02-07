# == Schema Information
#
# Table name: orders
#
#  id                   :integer          not null, primary key
#  quantity             :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#  drawing_file_name    :string(255)
#  drawing_content_type :string(255)
#  drawing_file_size    :integer
#  drawing_updated_at   :datetime
#  name                 :string(255)
#  deadline             :date
#  supplier_message     :text
#

class Order < ActiveRecord::Base
  attr_accessible :quantity, :drawing, :name, :deadline, :supplier_message, :is_over_without_winner
  has_attached_file :drawing,
  									:url => "/:attachment/:id/:style/:basename.:extension",
  									:path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
  
  belongs_to :user
  has_many :dialogues, dependent: :destroy

  validates :quantity, presence: true, numericality: {greater_than: 0}
  #validates_attachment :drawing, attachment_presence: true, attachment_size: {less_than: 50.megabytes}
  validates :user_id, presence: true
end
