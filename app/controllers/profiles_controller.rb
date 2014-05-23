class ProfilesController < ApplicationController

	def supplier_profile_redirect
		supplier = Supplier.find_by_name_for_link(params[:supplier_name].downcase)
		if supplier
			country_name_for_link = supplier.address.country.name_for_link
			state_name_for_link = supplier.address.state.name_for_link ||= 'all'
			redirect_to lookup_path(country_name_for_link, state_name_for_link, supplier.name_for_link),
				:status => :moved_permanently
		else
			render template: "suppliers/profile"
		end
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