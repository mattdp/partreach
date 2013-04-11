class DialoguesController < ApplicationController

	def new
		@dialogue = Dialogue.new
		#@order = Order.find(params[:id])
		@suppliers = Supplier.all

		respond_to do |format|
			format.html
      format.json { render json: @dialogue }
    end
	end

	def create

		@order = Order.find(params[:id])

		did_dialogue_save = true

		if did_dialogue_save
			format.html { redirect_to @order, notice: 'Dialogue added to order.' }
      format.json { render json: @order, status: :created, location: @order }
		else 
			format.html { render action: "new" }
      format.json { render json: @dialogue.errors.full_messages, status: 400 }
    end
  end

end