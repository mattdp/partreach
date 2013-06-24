class DialoguesController < ApplicationController
	before_filter :admin_user, only: [:new, :create]

	def new
		@suppliers = sort_suppliers(Supplier.all)
		@tags = Tag.all
		@family_names_and_tags = Tag.family_names_and_tags
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
			
			@tag_ids = params[:tag_selection]
			@country = params[:country_selection][0] if params[:country_selection]
			@state = params[:state] if !params[:state].nil? and params[:state] != ""

			@supplier_ids.each do |s_id|

				s = Supplier.find(s_id)

				if @tag_ids and @tag_ids.size > 0
					@tag_ids.each do |t_id|
						saved_ok = false unless s.send "#{params[:form_use]}", t_id
					end
				end

				if @country 
					if s.address
						s.address.country = @country
					else
						s.address = Address.create(:country => @country)
					end
				end

				if @state
					if s.address
						s.address.state = @state
					else
						s.address = Address.create(:state => @state)
					end
				end

				s.address.save if @country or @state

			end

			redir_to = "/dialogues/new"
			redir_notice = "#{params[:form_use]} to suppliers."

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

  private

  	def sort_suppliers(all_suppliers)
  		all_suppliers.sort_by! { |s| s.name.downcase }
  	end

end