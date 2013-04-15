# == Schema Information
#
# Table name: orders
#
#  id                     :integer          not null, primary key
#  quantity               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :integer
#  drawing_file_name      :string(255)
#  drawing_content_type   :string(255)
#  drawing_file_size      :integer
#  drawing_updated_at     :datetime
#  name                   :string(255)
#  deadline               :date
#  supplier_message       :text
#  is_over_without_winner :boolean
#  recommendation         :string(255)
#  material_message       :text
#  next_steps             :text
#  suggested_suppliers    :string(255)
#  drawing_units          :string(255)
#

class Order < ActiveRecord::Base
  attr_accessible :quantity, :drawing, :name, :deadline, :supplier_message, :is_over_without_winner, :material_message, :next_steps, :suggested_suppliers, :drawing_units
  has_attached_file :drawing,
  									:url => "/:attachment/:id/:style/:basename.:extension",
  									:path => ":rails_root/public/:attachment/:id/:style/:basename.:extension"
  
  belongs_to :user
  has_many :dialogues, dependent: :destroy

  validates :quantity, presence: true, numericality: {greater_than: 0}
  validates :user_id, presence: {message: "needs a name, valid email, and >= 6 character password"}
  validates :material_message, presence: true, length: {minimum: 2}
  validates :drawing_units, presence: true, length: {minimum: 1}
end
