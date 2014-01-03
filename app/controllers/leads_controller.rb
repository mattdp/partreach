class LeadsController < ApplicationController

	def create
		@lead = Lead.create
		@lead_contact = LeadContact.create({email: params[:email_field],
																				contactable_id: @lead.id,
																				contactable_type: "Lead"
																				})

		next_step = params[:next_step_field]

		flash[:success] = "Thanks! We'll keep you posted."
		redirect_to next_step
	end

end