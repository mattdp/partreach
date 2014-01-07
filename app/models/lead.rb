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
#  notes                :text
#

class Lead < ActiveRecord::Base

	has_one :lead_contact, :as => :contactable, :dependent => :destroy
  has_many :communications, as: :communicator, :dependent => :destroy

  def self.next_contact_leads_sorted(only_after_today=true)
    if only_after_today
      where_clause = "next_contact_date IS NOT NULL AND next_contact_date <= '#{Date.today.to_s}'"
    else
      where_clause = "next_contact_date IS NOT NULL"
    end

    return Lead.where(where_clause).order("next_contact_date ASC")
  end

end
