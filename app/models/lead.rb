# == Schema Information
#
# Table name: leads
#
#  id                   :integer          not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  email_valid          :boolean          default(TRUE)
#  email_subscribed     :boolean          default(TRUE)
#  source               :string(255)      default("manual")
#  next_contact_date    :date
#  next_contact_content :string(255)
#  company              :string(255)
#  title                :string(255)
#  notes                :text
#

class Lead < ActiveRecord::Base

	has_one :lead_contact, :as => :contactable, :dependent => :destroy
  has_many :communications, as: :communicator, :dependent => :destroy

end
