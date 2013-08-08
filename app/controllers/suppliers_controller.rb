#add examiner to user, have it be either examiner 
#need before_filters to have supporting text
#need supplier fetcher method
#need to show all, some, or none (with message) depending on return
#need update to delete or untag appropriately

class SuppliersController < ApplicationController
	include SuppliersHelper
	before_filter :admin_user, only: [:new, :create]
	before_filter :examiner_user, only: [:setup_examinations, :submit_examinations]
	before_filter :correct_supplier_for_user, only: [:edit, :update]
	helper_method :state_sort

	def new
		@tags = Tag.all
		@family_names_and_tags = Tag.family_names_and_tags
	end

	def create
		@supplier = Supplier.new

		@supplier.name = params[:name]
		@supplier.url_main = params[:url_main] if !(params[:url_main].nil? or params[:url_main] == "")
		@supplier.description = params[:description] if !(params[:description].nil? or params[:description] == "")
		@supplier.source = params[:source] if !(params[:source].nil? or params[:source] == "")
		@supplier.email = params[:email] if !(params[:email].nil? or params[:email] == "")
		@supplier.phone = params[:phone] if !(params[:phone].nil? or params[:phone] == "")
		@supplier.profile_visible = true if params[:profile_visible] == "1"
		@supplier.name_for_link = Supplier.proper_name_for_link(@supplier.name)
		@supplier.create_or_update_address(	country: params[:country],
																				state: params[:state],
																				zip: params[:zip])

		saved_ok = @supplier.save and @supplier.address.save

		@tag_ids = params[:tag_selection]
		if @tag_ids and @tag_ids.size > 0
			@tag_ids.each do |t_id|
				saved_ok = false unless @supplier.add_tag(t_id)
			end
		end

		note = ""
		if saved_ok
			note = "Saved OK!" 
		else 
			note = "Saving problem."
		end

		redirect_to new_dialogue_path, notice: note
	end

	def index
		@visibles = Supplier.visible_profiles_sorted
	end

	def edit
		@supplier = Supplier.find(params[:id])
	end

	def update
		@supplier = Supplier.find(params[:id])

		@supplier.suggested_description = params[:suggested_description]
		@supplier.suggested_machines = params[:suggested_machines]
		@supplier.suggested_preferences = params[:suggested_preferences]

		@supplier.save
		UserMailer.email_internal_team(
			"Supplier profile edit: #{@supplier.name}",
			"They changed their suggested description or machines."
			)
		redirect_to edit_supplier_path(@supplier), notice: "Suggestions received!"
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

end