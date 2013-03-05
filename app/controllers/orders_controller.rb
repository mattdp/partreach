class OrdersController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: [:edit, :update, :show, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = current_user.orders

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new

    @order = Order.new
    @suppliers = Supplier.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
    @suppliers = Supplier.all
  end

  # POST /orders
  # POST /orders.json
  def create

    @order = Order.new#(params[:order])
    @order.quantity = params[:quantity_field]
    @order.user_id = current_user.id
    @order.drawing = params[:drawing]
    @order.name = params[:name_field]
    if !params[:deadline].nil?
      @order.deadline = Date.new(params[:deadline][:year].to_i, params[:deadline][:month].to_i, params[:deadline][:day].to_i) 
    end
    @order.supplier_message = params[:supplier_message_field]
    did_order_save = @order.save

    did_dialogues_save = false
    if not(params["supplier_list"].nil?)
      did_dialogues_save = true #default yes, if have a supplier
      params["supplier_list"].each do |s|
        d = Dialogue.new
        d.order_id = @order.id 
        d.supplier_id = s.to_i
        d.save and did_dialogues_save ? did_dialogues_save = true : did_dialogues_save = false #if fail once, should fail the rest of the times
      end
    end

    respond_to do |format|
      if did_order_save and did_dialogues_save
        text_notification("#{brand_name}: New order created by #{current_user.email}. Go get them some quotes!") if Rails.env.production?
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render json: @order, status: :created, location: @order }
      else
        @suppliers = Supplier.all
        if not(did_dialogues_save)
          @order.errors.messages[:supplier] = ["must have at least one checked company"]
        end
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    @order = Order.find(params[:id])

    if params[:submitting_page] and params[:submitting_page] == "orders_show"

      if @order.is_over_without_winner and params[:won] and params[:won] != "0"
        @order.is_over_without_winner = false
        @order.save
      end

      if !@order.is_over_without_winner and params[:won] and params[:won] == "0"
        @order.is_over_without_winner = true
        @order.save
      end

      @order.dialogues.each do |d|
        [:further_negotiation, :won].each do |attribute|
          if params[attribute] and params[attribute].include? d.id.to_s
            d[attribute] = true
          elsif params[attribute] and not params[attribute].include? d.id.to_s
            d[attribute] = false
          else #params[attribute].nil?
            d[attribute] = false
          end  
        end
        d.save
      end
    end

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "show" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end

  private

    def correct_user
      @orders = current_user.orders.find_by_id(params[:id])
      redirect_to(root_path) if @orders.nil?
    end

    def text_notification(message_text)
      phone_numbers = ["+14152382438","+16033205765"] #matt, rob
    
      account_sid = 'AC019c83da8ef75c162b430e909464f5a4'
      auth_token = '21b3ac20f26865a84b05b9c8d7f54283'
      @client = Twilio::REST::Client.new account_sid, auth_token

      phone_numbers.each do |p|
        message = @client.account.sms.messages.create(:body => message_text,
        :to => p,
        :from => "+14154198194")
    end 

  end

end


