#add examiner to user, have it be either examiner 
#need before_filters to have supporting text
#need supplier fetcher method
#need to show all, some, or none (with message) depending on return
#need update to delete or untag appropriately

class SuppliersController < ApplicationController
	include SuppliersHelper
	before_filter :admin_user, only: [:new, :create, :admin_edit, :admin_update]
	before_filter :examiner_user, only: [:setup_examinations, :submit_examinations]
	before_filter :correct_supplier_for_user, only: [:edit, :update]
	helper_method :state_sort

	def new
		@supplier = Supplier.new
		@address = Address.new
		@family_names_and_tags = Tag.family_names_and_tags
	end

	def create

		@supplier = Supplier.new(admin_params)
		@supplier.name_for_link = Supplier.proper_name_for_link(@supplier.name)
		@supplier.create_or_update_address(address_params)

		@tag_ids = params[:tag_selection]
		if @tag_ids and @tag_ids.size > 0
			@tag_ids.each do |t_id|
				saved_ok = false unless @supplier.add_tag(t_id)
			end
		end

		if @supplier.save
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to new_supplier_path, notice: note
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
		redirect_to admin_edit_path(@supplier), notice: "Save attempted. NOT YET IMPLEMENTED"
	end

	def update
		@supplier = Supplier.find(params[:id])
		@supplier.update_attributes(supplier_params)
		
		UserMailer.email_internal_team(
			"Supplier profile edit: #{@supplier.name}",
			"They changed their suggested description, machines, services, or preferences."
			)
		redirect_to edit_supplier_path(@supplier), notice: "Suggestions received! We'll be in touch once they're reviewed."
	end

	def setup_examinations
		@questionables = Supplier.quantity_by_tag_id(50,Tag.find_by_name("datadump").id)
	end

	#faster if batch load suppliers
	def submit_examinations
		datadump_id = Tag.find_by_name("datadump").id
		params[:suppliers].each do |s_id,v|
			supplier = Supplier.find(s_id)
			if v == "duplicate"
				supplier.destroy
			elsif v == "not_duplicate"
				supplier.update_attributes({name: params[:supplier_names][s_id]})
				supplier.create_or_update_address({ country: params[:supplier_countries][s_id], 
																						state: params[:supplier_states][s_id],
																						zip: params[:supplier_zips][s_id]
																					})
				supplier.remove_tag(datadump_id)
			end
		end

		redirect_to setup_examinations_path, notice: "Examinations submitted."
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