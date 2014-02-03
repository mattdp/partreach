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
		@address.country = Geography.new
		@address.state = Geography.new
		@family_names_and_tags = Tag.family_names_and_tags
		@billing_contact = BillingContact.new
		@contract_contact = ContractContact.new
		@rfq_contact = RfqContact.new
	end

	def create
		params = clean_params

		@supplier = Supplier.new(admin_params)
		@supplier.name_for_link = Supplier.proper_name_for_link(@supplier.name)
		@supplier.create_or_update_address(address_params)
		Contact.create_or_update_contacts(@supplier,params)

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
		filter_name = "unitedstates-3dprinting"
		@visibles, @supplier_count = Rails.cache.fetch filter_name, :expires_in => 25.hours do |key|
			logger.debug "Cache miss: #{filter_name}"
			filter = Filter.find_by_name(filter_name)
			Supplier.visible_profiles_sorted(filter)
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
		track("supplier","viewed_edit_page",@supplier.id)
	end

	def admin_edit
		@supplier = Supplier.where("name_for_link = ?", params[:name].downcase).first
		@tags = @supplier.tags
		@address = @supplier.address
		@family_names_and_tags = Tag.family_names_and_tags
		@claimant = User.find_by_supplier_id(@supplier.id)
		@machines_quantity_hash = @supplier.machines_quantity_hash
		@dialogues = Dialogue.where("supplier_id = ?",@supplier.id).order("created_at desc")
		@communications = Communication.where("communicator_id = ? AND communicator_type = 'Supplier'",@supplier.id).reverse
		@billing_contact = @supplier.billing_contact
		@contract_contact = @supplier.contract_contact
		@rfq_contact = @supplier.rfq_contact
	end

	def admin_update
		params = clean_params
		@supplier = Supplier.find(params[:id])
		@supplier.assign_attributes(admin_params)
		@supplier.name_for_link = Supplier.proper_name_for_link(@supplier.name)
		@supplier.create_or_update_address(address_params)
		Contact.create_or_update_contacts(@supplier,params)

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
		track("supplier","submitted_profile_edits",@supplier.id)

		redirect_to edit_supplier_path(@supplier), notice: "Suggestions received! We'll be in touch once they're reviewed."
	end

	private

		def admin_params
			params.permit(:name, :name_for_link, :url_main, :url_materials, :description, \
  									:email, :phone, :source, :profile_visible, :claimed, \
  									:suggested_description, :suggested_machines, :suggested_preferences, \
  									:internally_hidden_preferences, :suggested_services, :suggested_address, \
  									:suggested_url_main, :points, :next_contact_date, :next_contact_content
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