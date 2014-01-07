# == Schema Information
#
# Table name: contacts
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  phone            :string(255)
#  email            :string(255)
#  method           :string(255)
#  notes            :text
#  type             :string(255)
#  contactable_id   :integer
#  contactable_type :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  first_name       :string(255)
#  last_name        :string(255)
#  title            :string(255)
#  company          :string(255)
#  linkedin_url     :string(255)
#

class Contact < ActiveRecord::Base
	belongs_to :contactable, polymorphic: true

	#will need to expand to allow different models
	def self.create_or_update_contacts(model,parameters)
    updatables = {
    								"Supplier" => { 
	    								:billing_contact => BillingContact, 
	    								:contract_contact => ContractContact,
	    								:rfq_contact => RfqContact
    								}
    							}					

    updatables[model.class.to_s].each do |method_name,class_name|
    	if parameters[method_name].present?
    		cleaner_parameters = parameters[method_name].delete_if { |k,v| v.nil? or v.empty?}
	    	if !model.send(method_name).present?
	    		model.send("#{method_name}=",class_name.create(cleaner_parameters))
	    	else
	    		model.send(method_name).update_attributes(cleaner_parameters)
	    	end
	    end
    end
	end

  def full_name_untrusted
  	if (self.first_name.present? or self.last_name.present?)
  		return "#{self.first_name} #{self.last_name}"
  	else
  		return "#{self.name}"
  	end
  end	

end
