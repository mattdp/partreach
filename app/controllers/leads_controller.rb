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
		@communications = Communication.where("communicator_id = ? AND communicator_type = 'Lead'",@lead.id).reverse
	end

	def update
		@lead = Lead.find(params[:id])
		@lead.update_attributes(lead_params)

		redirect_to edit_lead_path(@lead), notice: "Lead update attempted."
	end

	private

		def lead_params
			params.require(:lead).permit(	:first_name,:last_name,:source,:company,:title,:notes,\
																		:next_contact_date, :next_contact_content)
		end

end