class OrdersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :show, :destroy, :manipulate_dialogues]
  before_filter :correct_user, only: [:show, :destroy]
  before_filter :admin_user, only: [:manipulate_dialogues, :update_dialogues]

  # GET /orders
  # GET /orders.json
  def index
    @orders = current_user.orders
    @point_structure = Supplier.get_in_use_point_structure
    current_user.supplier_id.nil? ? @supplier = nil : @supplier = Supplier.find(current_user.supplier_id)

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
    @sorted_dialogues = sort_dialogues(@order.visible_dialogues)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new

    fs = params[:from_supplier]
    looking_for_supplier = Supplier.where("id = ?",fs.to_i) if not(fs.nil?)
    looking_for_supplier.present? ? @supplier = looking_for_supplier[0] : @supplier = nil

    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
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
    if (!params[:zip_field].nil? or !params[:country_field].nil?) and did_user_work
      if current_user.address.nil?
        a = Address.new()
        a.place_id = current_user.id
        a.place_type = "User"
        a.zip = params[:zip_field]
        a.country = params[:country_field]
        a.save
      elsif current_user.address.zip != params[:zip_field] or current_user.address.zip != params[:country_field]
        current_user.address.update_attributes({:zip => params[:zip_field], :country => params[:country_field]})
      end
    end
    @order.supplier_message = params[:supplier_message_field]
    did_user_work ? did_order_save = @order.save : did_order_save = false
    logger.debug "Order saving: #{did_order_save}"

    respond_to do |format|
      if did_user_work and did_order_save
        note = "#{brand_name}: Order created by #{current_user.email}, order number #{@order.id}. Go get quotes!"
        if Rails.env.production?
          text_notification(note) 
          UserMailer.email_internal_team("Order created",note)
        end
        format.html { redirect_to order_path(@order), notice: "Order successfully created. We'll be in touch by email soon to confirm!" }
        #this line is somehow needed in a way I don't understand
        format.json { render json: @order, status: :created, location: @order }
      else
        logger.debug "ERRORS: #{@order.errors.full_messages}" 
        format.html { render action: "new" }
        format.json { render json: @order.errors.full_messages, status: 400 }
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

    @order.recommendation = params[:recommendation]
    @order.next_steps = params[:next_steps]
    if params[:status].present?
      Event.add_event("Order",@order.id,"closed_successfully") if params[:status] == "Finished - closed" and @order.status != params[:status]
      @order.status = params[:status] 
    end
    @order.next_action_date = params[:next_action_date]
    @order.save ? logger.debug("Order #{@order.id} saved.") : logger.debug("Order #{@order.id} didn't save.")
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
    UserMailer.email_internal_team("Purchase attempted",note)
    respond_to do |format|
      format.html
      format.json { render json: @order }
    end
  end

  private

    def correct_user
      @orders = current_user.orders.find_by_id(params[:id])
      redirect_to(root_path) if (@orders.nil? and !current_user.admin)
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
      checkboxes = [:initial_select, :opener_sent, :response_received, :further_negotiation, :informed, :won, :recommended]
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
        elsif d.bid?
          completed << d
        elsif d.declined?
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


