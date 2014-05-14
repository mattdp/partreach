class ProfilesController < ApplicationController
	include ProfilesHelper

	def supplier_profile
		# toggle if certain parts of the profile are visible
		@machines_toggle = true
		@reviews_toggle = true
		@photos_toggle = false

		current_user.nil? ? @user_id = 0 : @user_id = current_user.id

		@supplier = Supplier.where("name_for_link = ?", params[:name].downcase).first
		@allowed = allowed_to_see?(@supplier)
		if @allowed
			@tags = @supplier.visible_tags if @supplier
			@machines_quantity_hash = @supplier.machines_quantity_hash
			@num_machines = @machines_quantity_hash.sum{|k,v| v}
			@num_reviews = @supplier.visible_reviews.count
			
			@meta = ""
			@meta += "Tags for #{@supplier.name} include " + andlist(@tags.take(3).map{ |t| "\"#{t.readable}\""}) + ". " if @tags.present?
			profile_factors = andlist(meta_for_supplier(@supplier))
			@meta += "The #{@supplier.name} profile has " + andlist(meta_for_supplier(@supplier)) + ". " if profile_factors.present?
			@meta = @meta.present? ? @meta : "#{@supplier.name} - Supplier profile"
		end
	end

	def supplier_profile_redirect
		supplier = Supplier.find_by_name_for_link('saturnmachineinc'.downcase)
		redirect_to supplier_geo_profile_path(
			supplier.address.country.name_for_link,
			supplier.address.state.name_for_link,
			supplier.name_for_link),
			:status => :moved_permanently
	end

	def machine_profile
		@beta = is_beta?
		@machine = Machine.find_by_name_for_link(params[:machine_name])
		@suppliers = Supplier.with_machine(@machine.id)
		@manufacturer = @allowed = nil
		if @machine
			@manufacturer = @machine.manufacturer
			@allowed = allowed_to_see?(@machine)
		end
	end

	def manufacturer_profile
		@beta = is_beta?
		@manufacturer = Manufacturer.find_by_name_for_link(params[:manufacturer_name])
		@machine = @allowed = nil		
		if @manufacturer
			@machines = @manufacturer.machines
			@allowed = allowed_to_see?(@manufacturer)
		end
	end

	def submit_ask
		a = Ask.new(supplier_id: params[:supplier_id], request: params[:request], user_id: params[:user_id])
		a.save
		@supplier = Supplier.find(params[:supplier_id])
		redirect_to supplier_profile_url(@supplier.name_for_link), notice: 'Suggestion received. Thanks!'
	end

	private

		def is_beta?
			true
		end

end