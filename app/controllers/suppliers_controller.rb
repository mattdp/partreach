#add examiner to user, have it be either examiner 
#need before_filters to have supporting text
#need supplier fetcher method
#need to show all, some, or none (with message) depending on return
#need update to delete or untag appropriately

class SuppliersController < ApplicationController
	include SuppliersHelper
	before_filter :admin_user, only: [:new, :create, :admin_edit, :admin_update]
	before_filter :correct_supplier_for_user, only: [:edit, :update]
	helper_method :state_sort

	def new
		@supplier = Supplier.new
		@address = Address.new
		@family_names_and_tags = Tag.family_names_and_tags
	end

	def create
		params = clean_params

		@supplier = Supplier.new(admin_params)
		@supplier.name_for_link = Supplier.proper_name_for_link(@supplier.name)
		@supplier.create_or_update_address(address_params)

		saved_ok = @supplier.save and @supplier.update_tags(params[:tag_selection])

		if saved_ok
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to admin_edit_path(@supplier.name_for_link), notice: note
	end

	#note that using "key" instead of the us_3d... caused failure
	def index
		@visibles = Rails.cache.fetch "us_3d_printing", :expires_in => 25.hours do |key|
			logger.debug "Cache miss: us_3d_printing"
			Supplier.visible_profiles_sorted("us_3d_printing")
		end
		@to_index = Rails.cache.fetch "us_states_of_visible_profiles", :expires_in => 25.hours do |key|
			logger.debug "Cache miss: us_states_of_visible_profiles"
			Address.us_states_of_visible_profiles 
		end
	end

	def edit
		@supplier = Supplier.find(params[:id])
		@tags = @supplier.visible_tags
		@machines_quantity_hash = @supplier.machines_quantity_hash
		@point_structure = Supplier.get_in_use_point_structure
	end

	def admin_edit
		@supplier = Supplier.where("name_for_link = ?", params[:name].downcase).first
		@tags = @supplier.tags
		@address = @supplier.address
		@family_names_and_tags = Tag.family_names_and_tags
		@claimant = User.find_by_supplier_id(@supplier.id)
		@machines_quantity_hash = @supplier.machines_quantity_hash
		@dialogues = Dialogue.where("supplier_id = ?",@supplier.id)
	end

	def admin_update
		params = clean_params
		@supplier = Supplier.find(params[:id])
		@supplier.assign_attributes(admin_params)
		@supplier.name_for_link = Supplier.proper_name_for_link(@supplier.name)
		@supplier.create_or_update_address(address_params)

		saved_ok = @supplier.save and @supplier.update_tags(params[:tag_selection])
		if saved_ok
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to admin_edit_path(@supplier.name_for_link), notice: note
	end

	def update
		params = clean_params
		@supplier = Supplier.find(params[:id])
	
		@supplier.update_attributes(supplier_params)
		
		UserMailer.email_internal_team(
			"Supplier profile edit: #{@supplier.name}",
			"They changed their suggested description, machines, services, or preferences."
			)
		redirect_to edit_supplier_path(@supplier), notice: "Suggestions received! We'll be in touch once they're reviewed."
	end

	private

		def admin_params
			params.permit(:name, :name_for_link, :url_main, :url_materials, :description, \
  									:email, :phone, :source, :profile_visible, :claimed, \
  									:suggested_description, :suggested_machines, :suggested_preferences, \
  									:internally_hidden_preferences, :suggested_services, :suggested_address, \
  									:suggested_url_main, :points
  									)
		end

		def supplier_params
			params.permit(:suggested_description, :suggested_machines, :suggested_preferences, \
										:suggested_services, :suggested_address, :url_main, :email, :phone
										)
		end

		def address_params
			params.permit(:country, :state, :zip)
		end

end