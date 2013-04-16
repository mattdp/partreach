class LeadsController < ApplicationController

	def create
		@lead = Lead.new
		@lead.email = params[:email_field]

		next_step = params[:next_step_field]

		@lead.save #no matter what, reload

		redirect_to next_step
	end

end