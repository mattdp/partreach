# == Schema Information
#
# Table name: leads
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Lead < ActiveRecord::Base
  attr_accessible :email

  validates :email, presence: true, length: {minimum: 2}
end
