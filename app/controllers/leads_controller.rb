class LeadsController < ApplicationController
	before_filter :admin_user, only: [:edit, :index, :update]

	def create
		@lead = Lead.create_or_update_lead({email: params[:email_field]})

		next_step = params[:next_step_field]

		flash[:notice] = "Thanks! We'll keep you posted."
		redirect_to next_step
	end

	def index
		@leads = Lead.sorted(true)
	end

	def edit
		@lead = Lead.find(params[:id])
		@lead_contact = @lead.lead_contact
		@user = @lead.user
		@communications = Communication.where("communicator_id = ? AND communicator_type = 'Lead'",@lead.id).reverse
		@text_field_setup = {
			"@lead_contact" => [:phone,:email,:name,:first_name,:last_name,:company,:title,:linkedin_url],
			"@lead" => [:source,:next_contact_content]
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
			params.permit(:source,:next_contact_date,:next_contact_content,:priority)
		end

		def lead_contact_params
			params.permit(:phone,:email,:first_name,:last_name,:name,:company,:title,:linkedin_url,:notes)
		end

end