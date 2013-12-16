class DialoguesController < ApplicationController
	before_filter :admin_user, only: [:new, :create]

	def new
		@structure = Rails.cache.fetch "dialogues_new_setup", :expires_in => 25.hours do |key|
			logger.debug "Cache miss: dialogues_new_setup"
			Dialogue.dialogues_new_setup
		end
		@family_names_and_tags = Tag.family_names_and_tags
		@countries = Geography.all_countries.map{|geo| geo.short_name}
		@us_states = Geography.all_us_states.map{|geo| geo.short_name}
	end

	def create

		saved_ok = true
		@supplier_ids = params[:supplier_selection]

		if params[:form_use] == "add_dialogues"

			@order = Order.find(params[:order_id_field])

			@supplier_ids.each do |s|
				@dialogue = Dialogue.new
				@dialogue.order_id = @order.id
				@dialogue.supplier_id = s.to_i
				saved_ok = false unless @dialogue.save
			end

			redir_to = "/manipulate/#{@order.id}"
			redir_notice = 'Dialogue added to order.'

		elsif params[:form_use] == "add_tag" or params[:form_use] == "remove_tag"
			
			@country = nil
			@state = nil
			@zip = nil

			@tag_ids = params[:tag_selection]
			@country = params[:country_selection][0] if params[:country_selection]
			@state = params[:state] if !params[:state].nil? and params[:state] != ""
			@zip = params[:zip] if !params[:zip].nil? and params[:zip] != ""

			@supplier_ids.each do |s_id|
				s = Supplier.find(s_id)
				s.rfq_contact.email = params[:email] if !params[:email].nil? and params[:email] != ""
				s.rfq_contact.phone = params[:phone] if !params[:phone].nil? and params[:phone] != ""
				s.rfq_contact.save				

				if @tag_ids and @tag_ids.size > 0
					@tag_ids.each do |t_id|
						saved_ok = false unless s.send "#{params[:form_use]}", t_id
					end
				end
				
				s.create_or_update_address(country: @country, state: @state, zip: @zip)
			end

			redir_to = "/dialogues/new"
			redir_notice = "#{params[:form_use]} to suppliers."

		elsif params[:form_use] == "refresh_cache"
			Rails.cache.write("dialogues_new_setup",Dialogue.dialogues_new_setup,:expires_in => 25.hours)
			redir_to = "/dialogues/new"
			redir_notice = "Cache reset attempted."
		else #should never happen
			saved_ok = false 
		end	

		respond_to do |format|
			if saved_ok
				format.html { redirect_to redir_to, notice: redir_notice }
			else 
				format.html { render action: "new" }
	      format.json { render json: @dialogue.errors.full_messages, status: 400 }
	    end
	  end
  end

end