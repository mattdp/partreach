class OrderGroupsController < ApplicationController
	before_filter :admin_user

	def new
		@order_group = OrderGroup.new
	end

	def create_default
		order_group = OrderGroup.create({name: "Default"})
		render json: order_group.id
	end

	def create
		@order_group = OrderGroup.create(order_group_params)
		@order = @order_group.order

		redirect_to manipulate_path(@order.id), notice: 'Order group create attempted.'
	end

	def edit
		@order_group = OrderGroup.find(params[:id])
	end

	def update
		@order_group = OrderGroup.find(params[:id])
		@order = @order_group.order

		@order_group.update_attributes(order_group_params)		

		redirect_to manipulate_path(@order.id), notice: 'Order group update attempted.'		
	end

	private

		def order_group_params
			params.require(:order_group).permit(:name,:process,:material,:order_id)
		end

end