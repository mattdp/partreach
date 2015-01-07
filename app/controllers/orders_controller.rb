class OrdersController < ApplicationController

  before_filter :signed_in_user, only: [:index, :destroy, :manipulate_dialogues]
  before_filter :correct_user, only: [:show, :destroy]
  before_filter :set_gon_order_id, only: [:show, :manipulate_dialogues]
  before_filter :admin_user, only: [:manipulate_dialogues, :update_dialogues, :manipulate_parts, :update_parts, :initial_email_edit, :initial_email_update]

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
    @order ||= Order.find(params[:id])
    @order_groups = @order.order_groups.order("created_at")
    @user = User.find(@order.user_id)
    @total_quantity = @order.total_quantity
    @recommended = @dialogues.select{|d| (d.recommended? and d.opener_sent)} if @dialogues = @order.dialogues
    if @order.columns_shown
      @columns = OrderColumn.get_columns(@order.columns_shown.to_sym)
    else
      @columns = OrderColumn.get_columns(:all)
    end

    unless current_user && current_user.admin
      if current_user == @order.user
        Event.add_event("Order", @order.id, "order viewed by owner")
      else
        Event.add_event("Order", @order.id, "order viewed using share link")
      end
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  def new
    @questions = params["questions"]
    @content = Question.raw_list

    @approximate_next_order_id = next_order_id

    @order = Order.new
    @order.order_groups.build
    @order.order_groups[0].parts.build
    @files_uploaded = nil
    @parts_list_uploaded = "false"
    respond_to do |format|
      format.html { render layout: "orders_new" } # new.html.erb
      format.json { render json: @order }
    end
  end

  # POST /orders
  #
  # consider making the whole thing a transaction
  #
  def create
    @order = Order.new(order_params)
    existed_already = false
    did_user_work = false
    did_order_save = false

    if current_user.nil?
      #they've filled out the signin form
      if params[:signin_email].present? && params[:signin_password].present?
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
            Lead.create_or_update_lead({
              lead: {user_id: @user.id},
              lead_contact: {name: params[:user_name], email: params[:user_email], phone: params[:user_phone]}
            })
          end
        end
      end
    else # there is a current user, already signed in
      @user = current_user
      existed_already = true
      did_user_work = true
    end

    if did_user_work
      @user.create_or_update_address({ zip: params[:zip] }) if params[:zip].present?

      did_order_save = validate_and_create
      logger.debug "Order saving: #{did_order_save}"
    else
      @order.errors.messages[:Sign_up_or_sign_in] = ["needs a valid email and password"]
    end

    respond_to do |format|
      if did_user_work && did_order_save
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
        @questions = {}
        @questions[:experience] = params["order"]["stated_experience"]
        @questions[:priority] = params["order"]["stated_priority"]
        @questions[:manufacturing] = params["order"]["stated_manufacturing"]
        @content = Question.raw_list

        @approximate_next_order_id = next_order_id

        @order.order_groups.build if @order.order_groups.empty?
        @order.order_groups[0].parts.build(quantity: 1) if @order.order_groups[0].parts.empty?

        @order_uploads = params["order_uploads"]
        @files_uploaded = ( (params["files_uploaded"] == "true") ? "true" : nil )
        @parts_list_uploaded = params["parts_list_uploaded"]

        format.html { render action: "new", layout: "orders_new" }
        format.json { render json: @order.errors.full_messages, status: 400 }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order ||= Order.find(params[:id])
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
    @order.update(email_snippet: params["email_snippet"])

    params["order_group_parts_snippets"].each do |id,text|
      order_group = OrderGroup.find(id)
      order_group.update(parts_snippet: text)
    end

    params["order_group_images_snippets"].each do |id,text|
      order_group = OrderGroup.find(id)
      order_group.update(images_snippet: text)
    end

    redirect_to initial_email_edit_path(@order), notice: "Master email saves attempted."
  end

  def manipulate_dialogues
    @order = Order.find(params[:id])
    @user = User.find(@order.user_id)
    @communications = Communication.get_ordered('Lead', @user.lead.id)

    respond_to do |format|
      format.html # manipulate_dialogues.html.erb
      format.json { render 'manipulate_dialogues' }
    end
  end


  # This method is horrendus.  MUST REFACTOR
  def update_dialogues
    @order = Order.find(params[:id])
    @dialogues = @order.dialogues
    @checkboxes = setup_checkboxes
    @textfields = setup_textfields
    @numberfields = setup_numberfields

    @order.process_confidence = params[:process_confidence]
    @order.recommendation = params[:recommendation]
    @order.notes = params[:notes]
    @order.columns_shown = params[:columns_shown]
    @order.next_steps = params[:next_steps]
    if params[:status].present?
      Event.add_event("Order",@order.id,"closed_successfully") if params[:status] == "Finished - closed" && @order.status != params[:status]
      @order.status = params[:status]
    end
    @order.next_action_date = params[:next_action_date]
    @order.save ? logger.debug("Order #{@order.id} saved.") : logger.debug("Order #{@order.id} didn't save.")
    @dialogues.each do |d|
      if !params[d.id.to_s].nil?
        d_params = params[d.id.to_s]

        [@checkboxes, @textfields, @numberfields].each do |set|
          set.each do |field|
              d[field.to_s] = d_params[field.to_s]
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
  end

  def update_parts
    @order = Order.find(params[:id])

    # create externals and associate with order
    if params["order_uploads"]
      params["order_uploads"].each do |upload|
        @order.externals.build(url: upload["url"], original_filename: upload["original_filename"])
      end
    end

    @order.update(order_params)

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
      params.require(:order).permit(
        :stated_experience, :stated_priority, :stated_manufacturing,
        :units, :deadline, :order_description, :supplier_message,
        order_groups_attributes: [:id, :name, parts_attributes: [:id, :name, :quantity, :material, :notes]]
      )
    end

  def validate_and_create
    # validate that parts have been added, or that user checked that a parts list was uploaded
    unless (params["parts_list_uploaded"] == "true") ||
           (@order.order_groups[0] && @order.order_groups[0].parts.present?)
      @order.errors.messages[:parts] = [": Please enter name, quantity, and material for at least one part."]
      return false
    end

    @order.user_id = current_user.id
    @order.notes = "#{params[:user_phone]} is user contact number for rush order" if params[:user_phone].present?
    @order.order_groups[0].init_default

    # create order, along with nested order_group and parts
    return false unless @order.save

    # create externals and associate with order
    if params["order_uploads"]
      params["order_uploads"].each do |upload|
        @order.externals.build(url: upload["url"], original_filename: upload["original_filename"])
      end

      # causes externals to be saved, with polymorphic reference to order set appropriately
      return false unless @order.save
    end

    # validate that at least one file was uploaded
    if @order.externals.empty?
      @order.errors.messages[:uploads] = [": Please upload least one file."]
      return false
    end

    # it's all good
    return true
  end

    def correct_user
      @order = Order.find_by_id(params[:id])
      if current_user
        return if current_user.admin
        signed_in_user
        redirect_to(root_path) unless @order && (current_user == @order.user)
      else
        redirect_to(root_path) unless valid_view_token? && (action_name == 'show')
        @using_view_token = true
      end
    end

    def valid_view_token?
      params[:view_token] && @order && (params[:view_token] == @order.view_token)
    end

    def text_notification(message_text)
      phone_numbers = ["+14152382438","+16033205765","+14156565920"] #matt, rob, steve

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
      checkboxes = [:initial_select, :opener_sent, :supplier_working, :response_received, :informed, :won, :recommended, :billable]
    end

    def setup_textfields
      textfields = [:material, :process_name, :process_time, :shipping_name, :notes, :currency, :internal_notes, :past_experience]
    end

    def setup_numberfields
      numberfields = [:order_group_id, :supplier_id, :process_cost, :shipping_cost, :total_cost]
    end

    def set_gon_order_id
      gon.order_id = params[:id]
    end

    def next_order_id
      # what next order id will (likely) be
      # used for naming the folder of part files on S3
      # NOTE that two different sessions could end up getting the same id using this method
      # but that's good enough for this usage (it helps to have a rough order for manual troubleshooting)
      # "programmatic links to the files won't have the race conditions this creates" MDP -- huh?
      Order.max_id + 1
    end

end


