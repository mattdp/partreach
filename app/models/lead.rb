# == Schema Information
#
# Table name: leads
#
#  id                   :integer          not null, primary key
#  created_at           :datetime
#  updated_at           :datetime
#  source               :string(255)      default("manual")
#  next_contact_date    :date
#  next_contact_content :string(255)
#  notes                :text
#  priority             :string(255)
#  user_id              :integer
#  next_contactor       :string(255)
#

class Lead < ActiveRecord::Base

  belongs_to :user
	has_one :lead_contact, :as => :contactable, :dependent => :destroy
  has_many :communications, as: :communicator, :dependent => :destroy
 
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

  #supports :source, :name, :email, :phone
  def self.create_or_update_lead(parameters,user_id=nil)
    lead = nil
    if parameters[:email]
      lcs = LeadContact.where("email = ?", parameters[:email])
      lead = lcs[0].contactable if lcs.length > 0
    end
    if lead.nil?
      lead = Lead.create
      lc = LeadContact.create({contactable_id: lead.id, contactable_type: "Lead"})
    end

    lead.update_attributes({source: parameters[:source], user_id: user_id})
    lc = lead.lead_contact
    lc.update_attributes({name: parameters[:name], email: parameters[:email], phone: parameters[:phone]})
    return lead
  end

  #should make a general 'targeter' method once building the second one
  def self.cold_meche_reachout_april2014_targeter(max_targets,source="linkedin_task_april2014",communication_name="cold_meche_reachout_april2014")
    leads = Lead.where("source = ?",source)
    leads = leads.select{|l| !Communication.has_communication?(l,communication_name)}
    leads = leads.take(max_targets)
    return leads.map{|l| l.lead_contact}
  end

end
