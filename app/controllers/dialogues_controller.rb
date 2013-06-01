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

		if params[:form_use] == "add_dialogues"

			@supplier_ids.each do |s|
				@dialogue = Dialogue.new
				@dialogue.order_id = @order.id
				@dialogue.supplier_id = s.to_i
				saved_ok = false unless @dialogue.save
			end

			redir_to = "/orders/manipulate_dialogues/#{@dialogue.order_id}"
			redir_notice = 'Dialogue added to order.'

		elsif params[:form_use] == "add_tags"
			
			@tag_ids = params[:tag_selection]

			@supplier_ids.each do |s|
				@tag_ids.each do |t|
					@combo = Combo.new
					@combo.supplier_id = s.to_i
					@combo.tag_id = t.to_i
					saved_ok = false unless @combo.save
				end
			end

			redir_to = "/orders"
			redir_notice = 'Tags added to suppliers.'

		elsif params[:form_use] == "remove_tags"

			@tag_ids = params[:tag_selection]

			@supplier_ids.each do |s|
				@tag_ids.each do |t|
					c = Combo.where("supplier_id = ? AND tag_id = ?", s.to_i, t.to_i)
					Combo.destroy_all(supplier_id: s.to_i, tag_id: t.to_i) unless c.nil?
				end
			end
			
			redir_to = "/orders"
			redir_notice = 'Tags removed from suppliers.'

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