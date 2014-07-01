class OrdersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :show, :destroy, :manipulate_dialogues]
  before_filter :correct_user, only: [:show, :destroy]
  before_filter :admin_user, only: [:manipulate_dialogues, :update_dialogues, :manipulate_parts, :update_parts, :initial_email_edit, :initial_email_update]
  include UrlHelper

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
    @order_groups = @order.order_groups.order("created_at")
    @user = User.find(@order.user_id)
    @total_quantity = @order.total_quantity
    @recommended = @dialogues.select{|d| (d.recommended? and d.opener_sent)} if @dialogues = @order.dialogues
    track("order","viewed",@order.id)
    if @order.columns_shown
      @columns = OrderColumn.get_columns(@order.columns_shown.to_sym)
    else
      @columns = OrderColumn.get_columns(:all)
    end

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

    blanks = "__________"
    questions = params["questions"]
    [:experience, :priority, :manufacturing].each do |summary_var|
      value = blanks
      if questions.present? and questions[summary_var].present?
        option_details = Question.get_option_details(summary_var,questions[summary_var])
        if option_details
          value = option_details[:summary]
          instance_variable_set("@#{summary_var}",questions[summary_var])
        end
      end
      instance_variable_set("@#{summary_var}_summary_wording",value)
    end

    @order = Order.new
    #goal: for naming the folder of part files on S3, be close though not exact to what next order will be - it helps to have a rough order for manual troubleshooting
    #programmatic links to the files won't have the race conditions this creates
    @approximate_next_order_id = Order.order("created_at desc").limit(1)[0].id + 1

    @order_group = OrderGroup.create_default

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # POST /orders
  # POST /orders.json


  #
  # consider making the whole thing a transaction
  #
  def create
    existed_already = false
    did_user_work = false
    @order = Order.new
    @order_group = OrderGroup.find(params['order_group_id'])
    did_order_save = false
    if current_user.nil?
      #they've filled out the signin form
      if params[:signin_email] != "" and params[:signin_password] != ""
        #how pass in email and password, get signed in user?
        if (@lead_contact = LeadContact.find_by_email(params[:signin_email]) \
            and @user = @lead_contact.contactable.user \
            and @user.authenticate(params[:signin_password])
            )
          sign_in @user
          did_user_work = true
        else
          @user = nil
          did_user_work = false
        end
      #signin form not filled out, assuming a new user
      else
        if (lc = LeadContact.find_by_email(params[:user_email])) && lc.contactable.user
          # email entered by user is already associated with some other user
          did_user_work = false
        else
          @user = User.new(
            password: params[:user_password],
            password_confirmation: params[:user_password]
            )
          if @user.save
            sign_in @user
            did_user_work = true
            Lead.create_or_update_lead(
              {name: params[:user_name], email: params[:user_email], phone: params[:user_phone]},
              @user.id
            )
          end
        end
      end
    else # there is a current user, already signed in
      @user = current_user
      existed_already = true
      did_user_work = true
    end

    if did_user_work
      @order.user_id = current_user.id

      @order.columns_shown = "all"
      @order.notes = "#{params[:user_phone]} is user contact number for rush order" if params[:user_phone].present?
      @order.assign_attributes(order_params)
      if (!params[:zip].nil? or !params[:country].nil?)
        @user.create_or_update_address({ zip: params[:zip], country: params[:country] })
      end

      @order.order_groups << @order_group

      did_order_save = @order.save
      logger.debug "Order saving: #{did_order_save}"
    else
      @order.errors.messages[:Sign_back_in] = ["with a valid email and password"]
    end

    respond_to do |format|
      if did_user_work and did_order_save
        track("order","created",@order.id)
        track("order","created_by_repeat_user",@order.id) if existed_already
        note = "#{brand_name}: Order created by #{current_user.lead.lead_contact.email}, order number #{@order.id}. Go get quotes!"
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

  def initial_email_edit
    @order = Order.find(params[:id])
  end

  def initial_email_update
    @order = Order.find(params[:id])
    @order.update_attributes(order_params)

    params["order_group_email_snippets"].each do |id,text|
      order_group = OrderGroup.find(id)
      order_group.email_snippet = text
      order_group.save
    end

    redirect_to initial_email_edit_path(@order), notice: "Master email saves attempted."
  end

  def manipulate_dialogues
    @order = Order.find(params[:id])
    @order_groups = @order.order_groups.order("created_at")
    @user = User.find(@order.user_id)
    @lead_contact = @user.lead.lead_contact
    @total_quantity = @order.total_quantity

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
    @dialogues = @order.dialogues
    @checkboxes = setup_checkboxes
    @textfields = setup_textfields
    @numberfields = setup_numberfields

    @order.recommendation = params[:recommendation]
    @order.notes = params[:notes]
    @order.columns_shown = params[:columns_shown]
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
                when :order_group_id, :supplier_id
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

  def manipulate_parts
    @order = Order.find(params[:id])
    @order_groups = @order.order_groups.order("created_at")
    @total_quantity = @order.total_quantity
  end

  def update_parts
    @order = Order.find(params[:id])

    parts=params["order"]["part"]
    externals=parts.delete("external_attributes")
    Part.update(parts.keys, parts.values)
    External.update(externals.keys, externals.values)

    # TODO: redirect somewhere else (@orders?); add error handling
    # for now, redirect back to manipulate parts page
    respond_to do |format|
      format.html { redirect_to manipulate_parts_path(@order), notice: 'Order manipulated.' }
      format.json { head :no_content}
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

    def order_params
      params.permit(:name,:material_message,:suggested_suppliers, :deadline, \
        :stated_experience,:stated_priority,:stated_manufacturing,:supplier_message, \
        :email_snippet, :stated_quantity, :units)
    end

    def correct_user
      @orders = current_user.orders.find_by_id(params[:id])
      redirect_to(root_path) if (@orders.nil? and !current_user.admin)
    end

    def text_notification(message_text)
      phone_numbers = ["+14152382438","+16033205765","+12038852107"] #matt, rob, yossi

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
      checkboxes = [:initial_select, :opener_sent, :supplier_working, :response_received, :informed, :won, :recommended]
    end

    def setup_textfields
      textfields = [:material, :process_name, :process_time, :shipping_name, :notes, :currency, :internal_notes]
    end

    def setup_numberfields
      numberfields = [:order_group_id, :supplier_id, :process_cost, :shipping_cost, :total_cost]
    end

  #private doesn't 'end'

end


