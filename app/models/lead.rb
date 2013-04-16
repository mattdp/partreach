class Lead < ActiveRecord::Base
  attr_accessible :email

  validates :email, presence: true, length: {minimum: 2}
end
