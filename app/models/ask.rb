# == Schema Information
#
# Table name: asks
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  user_id     :integer
#  request     :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  real        :boolean
#

class Ask < ActiveRecord::Base

  has_one :supplier

  validates :supplier_id, presence: true
  validates :request, presence: true
end
