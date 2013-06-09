class ProfilesController < ApplicationController

	def supplier_profile
		# toggle if certain parts of the profile are visible
		@machines_toggle = true
		@reviews_toggle = true
		@photos_toggle = true

		@supplier = Supplier.where("lower(name) = ?", params[:name].downcase).first
	end

end