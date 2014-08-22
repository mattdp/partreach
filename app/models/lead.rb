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

  def self.create_or_update_lead(params)
    lc = LeadContact.find_or_initialize_by(email: params[:lead_contact][:email]) do |lc|
      lead = lc.contactable ? lc.contactable : Lead.new
      lead.update_attributes(params[:lead])
      params[:lead_contact].merge!({contactable_id: lead.id, contactable_type: "Lead"})
      lc.update_attributes(params[:lead_contact])
    end
    lc.contactable
  end

  #should make a general 'targeter' method once building the second one
  def self.cold_meche_reachout_april2014_targeter(max_targets,source="linkedin_task_april2014",communication_name="cold_meche_reachout_april2014")
    leads = Lead.where("source = ?",source)
    leads = leads.select{|l| !Communication.has_communication?(l,communication_name)}
    leads = leads.take(max_targets)
    return leads.map{|l| l.lead_contact}
  end

  #goal is all users, supplier contacts (not sales), people who added email via site
  def self.blog_post_reachout_targeter(max_targets=nil)
    user_lead_contacts = Lead.where("user_id IS NOT NULL").map{|lead| lead.lead_contact}
    supplier_contacts = User.where("supplier_id IS NOT NULL").map{|user| user.lead.lead_contact}
    email_form_leads = Lead.where("source = 'email_collector'").map{|lead| lead.lead_contact}
    collected_leads = user_lead_contacts.concat(supplier_contacts).concat(email_form_leads)

    # if email addresses are wanted, rather than Contacts:
    # collected_emails = collected_leads.compact \
    #                                   .select{ |contact| contact.email_valid && contact.email_subscribed } \
    #                                   .map{|contact| contact.email} \
    #                                   .uniq
    # max_targets.nil? ? collected_emails : collected_emails.take(max_targets)
  end

end
