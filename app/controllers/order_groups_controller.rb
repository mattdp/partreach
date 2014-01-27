class OrderGroupsController < ApplicationController
	before_filter :admin_user

	def new
		@order_group = OrderGroup.new
	end

	def create
		@order_group = OrderGroup.create(order_group_params)
		@order = @order_group.order

		redirect_to manipulate_path(@order.id), notice: 'Order group create attempted.'
	end

	def edit
		@order_group = OrderGroup.find(params[:id])
	end

	private

		def order_group_params
			params.require(:order_group).permit(:name,:process,:order_id)
		end

end