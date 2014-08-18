class TransferOrdersController < ApplicationController

  def create
    @order = Order.find(params[:order_id])
    #Need to implement EstablishNewOwner according to transfer_order_to_different_user.txt
    new_owner = EstablishNewOwner(params[:new_owner_email])
    @order.user = new_owner

    respond_with do |format|
      if @order.save
        format.json { render json: @order }
      else
        format.json { render json: @order.errors.full_messages }
      end
    end
  end

end