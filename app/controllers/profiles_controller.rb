class ProfilesController < ApplicationController

	def supplier_profile
		# toggle if certain parts of the profile are visible
		@machines_toggle = true
		@reviews_toggle = true
		@photos_toggle = false

		current_user.nil? ? @user_id = 0 : @user_id = current_user.id

		@supplier = Supplier.where("name_for_link = ?", params[:name].downcase).first
		@tags = @supplier.visible_tags
	end

	def submit_ask
		a = Ask.new(supplier_id: params[:supplier_id], request: params[:request], user_id: params[:user_id])
		a.save
		@supplier = Supplier.find(params[:supplier_id])
		redirect_to supplier_profile_url(@supplier.name), notice: 'Suggestion received. Thanks!'
	end

end