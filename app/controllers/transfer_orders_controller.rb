class TransferOrdersController < ApplicationController

  def create
    @order = Order.find(params[:order_id])
    #Need to implement EstablishNewOwner according to transfer_order_to_different_user.txt
    respond_to do |format|
      if OrderTransferor.new(@order).transfer(params[:new_owner_email])
        format.json { render json: @order }
      else
        format.json { render json: @order.errors.full_messages }
      end
    end
  end

end