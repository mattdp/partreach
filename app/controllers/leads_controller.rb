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
		@lead_contact = @lead.lead_contact
		@communications = Communication.where("communicator_id = ? AND communicator_type = 'Lead'",@lead.id).reverse
		@text_field_setup = {
			"@lead" => [:source,:next_contact_content],
			"@lead_contact" => [:name,:first_name,:last_name,:company,:title]
		}
	end

	def update
		@lead = Lead.find(params[:id])
		@lead.update_attributes(lead_params)
		@lead_contact = @lead.lead_contact
		@lead_contact.update_attributes(lead_contact_params)

		redirect_to edit_lead_path(@lead), notice: "Lead update attempted."
	end

	private

		def lead_params
			params.permit(:source,:next_contact_date,:next_contact_content)
		end

		def lead_contact_params
			params.permit(:first_name,:last_name,:name,:company,:title,:notes)
		end

end