class CommunicationsController < ApplicationController
	before_filter :admin_user

	def new
		@communication = Communication.new
	end

	def create
		@communication = Communication.new(communication_params)

		saved_ok = @communication.save
		if saved_ok
			note = "Communication saved OK!" 
		else 
			note = "Communication saving problem."
		end

		if @communication.communicator_type == "Supplier"
			redirect_to admin_edit_path(Supplier.find(@communication.communicator_id).name_for_link), notice: note
		elsif @communication.communicator_type == "Lead"
			redirect_to edit_lead_path(Lead.find(@communication.communicator_id)), notice: note
		else
			redirect_to root_path, notice: "Error in redirection code. Investigate."
		end
	end

	private

		def communication_params
			params.permit(:communicator_id, :communicator_type, :means_of_interaction, :interaction_title, :notes, :user_id)
		end

end