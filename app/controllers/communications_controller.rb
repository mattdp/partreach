class CommunicationsController < ApplicationController
	before_filter :admin_user

	def new
		@communication = Communication.new
	end

	def create
		@communication = Communication.new(communication_params)
		@supplier = Supplier.find(params[:supplier_id])

		saved_ok = @communication.save
		if saved_ok
			note = "Communication saved OK!" 
		else 
			note = "Communication saving problem."
		end

		binding.pry

		redirect_to admin_edit_path(@supplier.name_for_link), notice: note
	end

	private

		def communication_params
			params.permit(:means_of_interaction, :interaction_title, :notes, :supplier_id)
		end

end