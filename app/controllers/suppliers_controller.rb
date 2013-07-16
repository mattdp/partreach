class SuppliersController < ApplicationController
	before_filter :admin_user, only: [:new, :create]

	def new
		@tags = Tag.all
		@family_names_and_tags = Tag.family_names_and_tags
	end

	def create
		@supplier = Supplier.new

		@supplier.name = params[:name]
		@supplier.url_main = params[:url_main] if !(params[:url_main].nil? or params[:url_main] == "")
		@supplier.description = params[:description] if !(params[:description].nil? or params[:description] == "")
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

end