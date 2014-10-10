class DialoguesController < ApplicationController
  before_filter :admin_user

  def new
    @suppliers = Supplier.suppliers_for_new_dialogue
    @tags_by_group = Tag.tags_by_group
    @countries = Geography.all_countries.pluck(:short_name)
    @us_states = Geography.all_us_states.pluck(:short_name)
    @order = params[:id] ? Order.find(params[:id]) : nil
  end

  def create

    saved_ok = true
    @supplier_ids = params[:supplier_selection]

    if params[:form_use] == "add_dialogues"

      @order = Order.find(params[:order_id_field])

      params[:order_group_use].each do |order_group_id|
        @order_group = OrderGroup.find(order_group_id)

        @supplier_ids.each do |s|
          @dialogue = Dialogue.new
          @dialogue.order_group_id = @order_group.id
          @dialogue.supplier_id = s.to_i
          saved_ok = false unless @dialogue.save
        end
      end

      redir_to = "/manipulate/#{@order.id}"
      redir_notice = 'Dialogue added to order.'

    elsif params[:form_use] == "add_tag" or params[:form_use] == "remove_tag"
      
      @country = nil
      @state = nil
      @zip = nil

      @tag_ids = params[:tag_selection]
      @country = params[:country_selection][0] if params[:country_selection]
      @state = params[:state] if !params[:state].nil? and params[:state] != ""
      @zip = params[:zip] if !params[:zip].nil? and params[:zip] != ""

      @supplier_ids.each do |s_id|
        s = Supplier.find(s_id)
        s.rfq_contact.email = params[:email] if !params[:email].nil? and params[:email] != ""
        s.rfq_contact.phone = params[:phone] if !params[:phone].nil? and params[:phone] != ""
        s.rfq_contact.save        

        if @tag_ids and @tag_ids.size > 0
          @tag_ids.each do |t_id|
            saved_ok = false unless s.send "#{params[:form_use]}", t_id
          end
        end
        
        s.create_or_update_address(country: @country, state: @state, zip: @zip)
      end

      redir_to = "/dialogues/new"
      redir_notice = "#{params[:form_use]} to suppliers."

    elsif params[:form_use] == "refresh_cache"
      @order = Order.find(params[:order_id_field])
      Rails.cache.write("dialogues_new_setup",Dialogue.dialogues_new_setup,:expires_in => 25.hours)
      redir_to = "/dialogues/new/#{@order.id}"
      redir_notice = "Cache reset attempted."
    else #should never happen
      saved_ok = false 
    end 

    respond_to do |format|
      if saved_ok
        format.html { redirect_to redir_to, notice: redir_notice }
      else 
        format.html { render action: "new" }
        format.json { render json: @dialogue.errors.full_messages, status: 400 }
      end
    end
  end

  #this isn't a real destroy method yet, as we wanted to orphan them first.  Likely will become one.
  def destroy
    @dialogue = Dialogue.find(params[:id])
    @dialogue.order_group_id = 0
    respond_to do |format|
      if @dialogue.save
        format.json {render json: {success: true}}
      else
        format.json {render json: {success: false}}
      end
    end
  end

  def initial_email
    @dialogue = Dialogue.find(params[:id])

    @supplier = @dialogue.supplier
    @order = @dialogue.order
    @contact = @supplier.rfq_contact
    @order_groups = @order.dialogues.select{|d| d.supplier_id == @supplier.id}.map{|d| d.order_group}

    content = @dialogue.initial_email_generator
    @subject = content[:subject]
    @body = content[:body]
  end

  def update_email_snippet
    @dialogue = Dialogue.find(params[:id])

    @dialogue.email_snippet = params[:email_snippet]
    @dialogue.save

    redirect_to dialogue_initial_email_path(@dialogue)
  end

  def send_initial_email
    @dialogue = Dialogue.find(params[:id])
    @order = @dialogue.order_group.order

    @dialogue.send_initial_email

    redirect_to manipulate_path(@order), notice: "Email send attempted."
  end

  def edit_rfq_close_email
    @dialogue = Dialogue.find(params[:id])
    @order = @dialogue.order
    @email_body = @dialogue.close_email_body
  end

  def generate_rfq_close_email
    @dialogue = Dialogue.find(params[:id])
    @supplier = @dialogue.supplier
    @contact = @supplier.rfq_contact
    @order = @dialogue.order
    @bidset = @dialogue.order_group.build_bidset
    @bids = @bidset.bids_sorted_by_price!
    @email_type = params[:email_type]

    case @email_type
    when "generic", "generic_with_check"
      render "basic_close_email", layout: false
    when "lost_bid_summary", "won_bid_summary"
      render "bid_summary_close_email", layout: false
    else
      render nothing: true, status: :bad_request
    end
  end

  def update_rfq_close_email
    @dialogue = Dialogue.find(params[:id])
    @dialogue.update(close_email_body: params[:email_body])
    if params["review"]
      redirect_to dialogue_review_rfq_close_email_path(@dialogue)
    else
      redirect_to dialogue_edit_rfq_close_email_path(@dialogue)
    end
  end

  def review_rfq_close_email
    @dialogue = Dialogue.find(params[:id])
    @supplier = @dialogue.supplier
    @contact = @supplier.rfq_contact
    @order = @dialogue.order
    @order_groups = @order.dialogues.select {|d| d.supplier_id == @supplier.id}.map{|d| d.order_group}

    @subject = "SupplyBetter RFQ ##{@dialogue.order.id}1 for #{@supplier.name}"
    @body = @dialogue.close_email_body
  end

  def send_rfq_close_email
    @dialogue = Dialogue.find(params[:id])
    @order = @dialogue.order

    @dialogue.send_rfq_close_email

    redirect_to manipulate_path(@order), notice: "Email send attempted."
  end

end