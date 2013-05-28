class DialoguesController < ApplicationController
	before_filter :admin_user, only: [:new, :create]

	def new
		@suppliers = Supplier.all
		@tags = Tag.all
	end

	def create

		saved_ok = true
		@order = Order.find(params[:order_id_field])
		@supplier_ids = params[:supplier_selection]
		@tag_ids = params[:tag_selection]

		if params[:form_use] == "add_dialogues"

			@supplier_ids.each do |s|

				@dialogue = Dialogue.new
				@dialogue.order_id = @order.id
				@dialogue.supplier_id = s.to_i
				if !@dialogue.save #replace with unless
					saved_ok = false
				end
			end
			redir_to = "/orders/manipulate_dialogues/#{@dialogue.order_id}"
			redir_notice = 'Dialogue added to order.'

		elsif params[:form_use] == "add_tags"
			
			@supplier_ids.each do |s|
				@tag_ids.each do |t|

					@combo = Combo.new
					@combo.supplier_id = s
					@combo.tag_id = t
					if !@combo.save
						saved_ok = false
					end
				end
			end
			redir_to = "/orders"
			redir_notice = 'Tags added to suppliers.'

		else #should never happen
			saved_ok = false 
		end	

		respond_to do |format|
			if saved_ok
				format.html { redirect_to redir_to, notice: redir_notice }
	      format.json { render json: @order, status: :created, location: @order }
			else 
				format.html { render action: "new" }
	      format.json { render json: @dialogue.errors.full_messages, status: 400 }
	    end
	  end
  end

end