class ProfilesController < ApplicationController

	def supplier_profile
		# toggle if certain parts of the profile are visible
		@machines_toggle = true
		@reviews_toggle = true
		@photos_toggle = true

		@supplier = Supplier.where("lower(name) = ?", params[:name].downcase).first
	end

	def submit_ask
		#create ask based on inbound information (where get?)
		#flash message of request received
		#route to that supplier profile
	end

end