class SuppliersController < ApplicationController
	before_filter :admin_user, only: [:new, :create]

	def new
	end

	def create
		@supplier = Supplier.new

		@supplier.name = params[:name]
		@supplier.url_main = params[:url_main] if !(params[:url_main].nil? or params[:url_main] == "")
		@supplier.address = Address.new
		@supplier.address.country = params[:country] if !(params[:country].nil? or params[:country] == "")
		@supplier.address.state = params[:state] if !(params[:state].nil? or params[:state] == "")
		@supplier.address.zip = params[:zip] if !(params[:zip].nil? or params[:zip] == "")

		note = ""
		if @supplier.save and @supplier.address.save
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to new_dialogue_path, notice: note
	end

	def index
		@suppliers = Supplier.visible_profiles
	end

end