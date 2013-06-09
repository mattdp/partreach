class ProfilesController < ApplicationController

	def supplier_profile
		@supplier = Supplier.where("lower(name) = ?", params[:name].downcase).first
	end

end