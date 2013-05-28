class DialoguesController < ApplicationController
	before_filter :admin_user, only: [:new, :create]

	def new
		@suppliers = Supplier.all
		@tags = Tag.all
	end

	def create

		saved_ok = true

		if params[:form_use] == "add_dialogues"
			@order = Order.find(params[:order_id_field])
			@supplier_ids = params[:supplier_selection]

			@supplier_ids.each do |s|

				@dialogue = Dialogue.new
				@dialogue.order_id = @order.id
				@dialogue.supplier_id = s.to_i
				if !@dialogue.save
					saved_ok = false
				end
			end
		elsif params[:form_use] == "add_tags"
			#tag logic
		else #should never happen
			saved_ok = false 
		end	

		respond_to do |format|
			if saved_ok
				format.html { redirect_to "/orders/manipulate_dialogues/#{@dialogue.order_id}", notice: 'Dialogue added to order.' }
	      format.json { render json: @order, status: :created, location: @order }
			else 
				format.html { render action: "new" }
	      format.json { render json: @dialogue.errors.full_messages, status: 400 }
	    end
	  end
  end

end