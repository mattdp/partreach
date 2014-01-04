class LeadsController < ApplicationController
	before_filter :admin_user, only: [:edit, :index, :update]

	def create
		@lead = Lead.create
		@lead_contact = LeadContact.create({email: params[:email_field],
																				contactable_id: @lead.id,
																				contactable_type: "Lead"
																				})

		next_step = params[:next_step_field]

		flash[:notice] = "Thanks! We'll keep you posted."
		redirect_to next_step
	end

	def index
		@leads = Lead.all
	end

	def edit
		@lead = Lead.find(params[:id])
	end

	def update
	end

end