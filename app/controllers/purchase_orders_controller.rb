class PurchaseOrdersController < ApplicationController
  before_filter :admin_user
  
  def edit
    @po = PurchaseOrder.find(params[:id])
    @tags = current_organization.provider_tags.sort_by { |t| t.readable.downcase }
    @checked_tags = @po.tags
  end

  def update
    @po = PurchaseOrder.find(params[:id])
    @provider = @po.provider
    saved_ok = false

    loop do     
      break unless @po.update_tags(params[:tag_selection])
      break unless @provider.update_tags(params[:tag_selection],false)
      new_tag_names = [params[:new_tag_1],params[:new_tag_2],params[:new_tag_3]].select {|tag_name| tag_name.present? }
      new_tag_names.each do |tag_name|
        tag = current_organization.find_or_create_tag!(tag_name,current_user)
        break unless tag.valid?
        @provider.tags << tag unless @provider.tags.include? tag
        @po.tags << tag unless @po.tags.include? tag
      end
      saved_ok = true
      break
    end

    if saved_ok
      redirect_to purchase_orders_path, notice: "Save successful."
    else
      redirect_to edit_purchase_order_path(@po.id), notice: "Save NOT successful. Investigate why."
    end
  end

  def index
    @pos = PurchaseOrder.order(created_at: :desc).limit(50)
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

    redirect_to purchase_orders_emails_path, notice: "Email sending logging attempted."
  end

end