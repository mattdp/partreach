class OrdersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :show, :destroy, :manipulate_dialogues]
  before_filter :correct_user, only: [:edit, :update, :show, :destroy]
  before_filter :admin_user, only: [:manipulate_dialogues, :update_dialogues]

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
    @user = User.find(@order.user_id)
    @sorted_dialogues = sort_dialogues(@order.dialogues)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new

    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create

    did_user_work = false
    if current_user.nil?
      #they've filled out the signin form
      if params[:signin_email_field] != "" and params[:signin_password_field] != ""
        #how pass in email and password, get signed in user?
        @user = User.find_by_email(params[:signin_email_field])
        if @user && @user.authenticate(params[:signin_password_field])
          sign_in @user
          did_user_work = true
        else
          @user = nil
          did_user_work = false
        end
      #signin form not filled out, assuming a new user
      else
        @user = User.create(name: params[:user_name_field], 
          email: params[:user_email_field], 
          password: params[:user_password_field], 
          password_confirmation: params[:user_password_field] )
        sign_in @user
        did_user_work = true
      end
    else # there is a current user, already signed in
      @user = current_user
      did_user_work = true
    end

    @order = Order.new
    if did_user_work
      @order.user_id = current_user.id
    else
      @order.errors.messages[:Sign_back_in] = ["with a valid email and password"]
    end
    @order.quantity = params[:quantity_field]
    @order.drawing_file_name = params[:file]
    @order.drawing_units = params[:drawing_units_field]
    @order.name = params[:name_field]
    @order.material_message = params[:material_message_field]
    @order.suggested_suppliers = params[:suggested_suppliers_field]
    if !params[:deadline].nil?
      @order.deadline = Date.new(params[:deadline][:year].to_i, params[:deadline][:month].to_i, params[:deadline][:day].to_i) 
    end
    if !params[:zip_field].nil? and did_user_work
      if current_user.address.nil?
        a = Address.new()
        a.place_id = current_user.id
        a.place_type = "User"
        a.zip = params[:zip_field]
        a.save
      elsif current_user.address.zip != params[:zip_field]
        current_user.address.update_attributes({:zip => params[:zip_field]}) 
      end
    end
    @order.supplier_message = params[:supplier_message_field]
    did_user_work ? did_order_save = @order.save : did_order_save = false
    logger.debug "Order saving: #{did_order_save}"

    respond_to do |format|
      if did_user_work and did_order_save
        text_notification("#{brand_name}: Order created by #{current_user.email}, order number #{@order.id}. Go get quotes!") if Rails.env.production?
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render json: @order, status: :created, location: @order }
      else
        logger.debug "ERRORS: #{@order.errors.full_messages}" 
        format.html { render action: "new" }
        format.json { render json: @order.errors.full_messages, status: 400 }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    @order = Order.find(params[:id])
    @sorted_dialogues = sort_dialogues(@order.dialogues)

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

  def manipulate_dialogues
    @order = Order.find(params[:id])
    @user = User.find(@order.user_id)
    @dialogues = sort_dialogues(@order.dialogues)
    @checkboxes = setup_checkboxes
    @textfields = setup_textfields
    @numberfields = setup_numberfields

    respond_to do |format|
      format.html # manipulate_dialogues.html.erb
      format.json { render json: @order }
    end
  end 

  def update_dialogues
    @order = Order.find(params[:id])
    @dialogues = sort_dialogues(@order.dialogues)
    @checkboxes = setup_checkboxes
    @textfields = setup_textfields
    @numberfields = setup_numberfields

    @dialogues.each do |d|
      if !params[d.id.to_s].nil?
        d_params = params[d.id.to_s]
        
        [@checkboxes, @textfields, @numberfields].each do |set|
          set.each do |field|
            if set == @checkboxes
              d_params[field.to_s].nil? ? d[field.to_s] = false : d[field.to_s] = true
            else

              field_value = d_params["#{field.to_s}_field"]
              if !field_value.nil?
                case field
                when :order_id, :supplier_id
                  if field_value != ""
                    d[field.to_s] = field_value.to_i
                  end
                when :process_cost, :shipping_cost, :total_cost
                  if field_value != ""
                    d[field.to_s] = BigDecimal.new(field_value)
                  end
                else
                  field_value == "" ? d[field.to_s] = nil : d[field.to_s] = field_value
                end
              end

            end
          end
        end

      end
      d.save
    end

    respond_to do |format|
      if true
        format.html { redirect_to @order, notice: 'Order manipulated.' }
        format.json { head :no_content}
      else
        format.html { render action: "manipulate_dialogues" }
        format.json { render json: @order.errors.full_messages, status: 400 }
      end
    end
  end

  def purchase
    @order = Order.find(params[:order])
    @dialogue = Dialogue.find(params[:dialogue])
    @supplier = Supplier.find(@dialogue.supplier_id)

    @dialogue.won = true
    note = "Purchase attempted. Order #{@order.id}, Supplier #{@supplier.name}"
    text_notification(note)
    UserMailer.purchase_attempted(note).deliver

    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  private

    def correct_user
      @orders = current_user.orders.find_by_id(params[:id])
      redirect_to(root_path) if (@orders.nil? && current_user.admin = false)
    end

    def text_notification(message_text)
      phone_numbers = ["+14152382438","+16033205765"] #matt, rob
    
      account_sid = 'AC019c83da8ef75c162b430e909464f5a4'
      auth_token = ENV['SB_TWILIO_AUTH_TOKEN']
      @client = Twilio::REST::Client.new account_sid, auth_token

      phone_numbers.each do |p|
        message = @client.account.sms.messages.create(:body => message_text,
        :to => p,
        :from => "+14154198194")
      end
    end 

    def setup_checkboxes
      checkboxes = [:initial_select, :opener_sent, :response_received, :further_negotiation, :won, :recommended]
    end
    
    def setup_textfields
      textfields = [:material, :process_name, :process_time, :shipping_name, :notes, :currency]
    end

    def setup_numberfields
      numberfields = [:order_id, :supplier_id, :process_cost, :shipping_cost, :total_cost]
    end

    def sort_dialogues(all_dialogues)
      # should be: 
      # recommended, in nonzero low to high
      # completed, in nonzero low to high
      # declined, alphabetical
      # pending, alphabetical
      answer = []

      recommended = []
      completed = []
      declined = []
      pending = []

      all_dialogues.each do |d|
        if d.recommended
          recommended << d 
        elsif d.response_received and (!d.total_cost.nil? and d.total_cost > 0)
          completed << d
        elsif d.response_received
          declined << d
        else
          pending << d
        end
      end

      [recommended, completed, declined, pending].each do |piece|
        answer.concat piece.sort_by! { |m| Supplier.find(m.supplier_id).name.downcase }
      end

      return answer
    end

  #private doesn't 'end'

end


