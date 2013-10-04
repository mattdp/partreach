class ProfilesController < ApplicationController
	include ProfilesHelper

	def supplier_profile
		# toggle if certain parts of the profile are visible
		@machines_toggle = true
		@reviews_toggle = true
		@photos_toggle = false

		current_user.nil? ? @user_id = 0 : @user_id = current_user.id

		@supplier = Supplier.where("name_for_link = ?", params[:name].downcase).first
		@tags = @supplier.visible_tags if @supplier
		@machines_quantity_hash = @supplier.machines_quantity_hash
		@num_machines = @machines_quantity_hash.sum{|k,v| v}
		@num_reviews = @supplier.visible_reviews.count
		@allowed = allowed_to_see_supplier_profile?(@supplier)
		
		@meta = ""
		@meta += "Tags for #{@supplier.name} include " + andlist(@tags.take(3).map{ |t| "\"#{t.readable}\""}) + ". " if @tags.present?
		profile_factors = andlist(meta_for_supplier(@supplier))
		@meta += "The #{@supplier.name} profile has " + andlist(meta_for_supplier(@supplier)) + ". " if profile_factors.present?

		@meta = @meta.present? ? @meta : "#{@supplier.name} - Supplier profile"
	end

	def submit_ask
		a = Ask.new(supplier_id: params[:supplier_id], request: params[:request], user_id: params[:user_id])
		a.save
		@supplier = Supplier.find(params[:supplier_id])
		redirect_to supplier_profile_url(@supplier.name_for_link), notice: 'Suggestion received. Thanks!'
	end

end