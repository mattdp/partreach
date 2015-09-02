class PurchaseOrdersController < ApplicationController
  before_filter :admin_user
  
  def edit
    @po = PurchaseOrder.find(params[:id])
  end

  def update
  end

  def index
    @pos = PurchaseOrder.order(created_at: :desc).limit(25)
  end

  def emails
    @structure = PurchaseOrder.users_and_email_suggestions
  end

  def email_sent
    @purchase_order = PurchaseOrder.find(params[:id])
    comment = @purchase_order.comment
    Event.create({happening: "sent_reminder_email", model: "User", model_id: comment.user_id,
      target_model: "Comment", target_model_id: comment.id})
    
    if (params[:after_this_email_count].present? and params[:after_this_email_count].to_i >= 3)
      @purchase_order.dont_request_feedback = true
      @purchase_order.save
    end

    redirect_to purchase_orders_path, notice: "Email sending logging attempted."
  end

end