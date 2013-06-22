class SuppliersController < ApplicationController
	before_filter :admin_user, only: [:new, :create]

	def new
	end

	def create
		@supplier = Supplier.new

		@supplier.name = params[:name]
		@supplier.url_main = params[:url_main]
		@supplier.address = Address.new
		@supplier.address.country = params[:country]
		@supplier.address.state = params[:state]
		@supplier.address.zip = params[:zip]

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