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
#  priority             :string(255)
#  user_id              :integer
#

class Lead < ActiveRecord::Base

  belongs_to :user
	has_one :lead_contact, :as => :contactable, :dependent => :destroy
  has_many :communications, as: :communicator, :dependent => :destroy
 
  validates_presence_of :lead_contact

  def self.sorted(all=true,only_after_today=true)
    if all
      leads = Lead.all
    else
      where_clause = "next_contact_date IS NOT NULL"
      where_clause += " AND next_contact_date <= '#{Date.today.to_s}'" if only_after_today
      leads = Lead.where(where_clause)
    end
    return leads.order(:priority,:next_contact_date)
  end

end
