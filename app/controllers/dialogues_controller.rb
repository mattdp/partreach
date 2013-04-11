class DialoguesController < ApplicationController
	before_filter :admin_user, only: [:new, :create]

	def new
		@suppliers = Supplier.all
	end

	def create

		@order = Order.find(params[:order_id_field])
		@supplier = Supplier.find(params[:supplier_selection])

		@dialogue = Dialogue.new
		@dialogue.order_id = @order.id
		@dialogue.supplier_id = @supplier.id

		respond_to do |format|
			if @dialogue.save
				format.html { redirect_to "/orders/manipulate_dialogues/#{@dialogue.order_id}", notice: 'Dialogue added to order.' }
	      format.json { render json: @order, status: :created, location: @order }
			else 
				format.html { render action: "new" }
	      format.json { render json: @dialogue.errors.full_messages, status: 400 }
	    end
	  end
  end

end