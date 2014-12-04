require "spec_helper"

describe "/orders requests" do

  describe "New order" do
    before do
      @user = FactoryGirl.create :user
      # sign in as registered user
      post sessions_path, { :session => { :email => @user.lead.lead_contact.email, :password => @user.password } }
    end

    it "with valid input, creates a new order" do
      post "/orders",
        "order_uploads"=>
          [{"url"=>
             "https://s3.amazonaws.com/supplybetter_test_file_upload/externals%2F301-1afbf063116d5041dab5a9d0a8d1bacc%2Fpart_a.txt",
            "original_filename"=>"part_a.txt"}],
        "files_uploaded"=>"true",
        "parts_list_uploaded"=>"false",
        "order"=>
          {"stated_experience"=>"",
           "stated_priority"=>"",
           "stated_manufacturing"=>"",
           "units"=>"mm.",
           "order_groups_attributes"=>
            {"0"=>
              {"parts_attributes"=>
                {"0"=>{"name"=>"Part A", "quantity"=>"1", "material"=>"ABS"}}}},
           "deadline"=>"",
           "order_description"=>"sample order description text",
           "supplier_message"=>""}

      follow_redirect!
      expect(response.body).to include("Order created")

      new_order = Order.last
      expect(new_order.order_groups[0].parts.size).to eq 1
      expect(new_order.order_description).to eq "sample order description text"
    end

    it "discards blank part rows and creates a new order" do
      post "/orders",
        "order_uploads"=>
          [{"url"=>
             "https://s3.amazonaws.com/supplybetter_test_file_upload/externals%2F301-1afbf063116d5041dab5a9d0a8d1bacc%2Fpart_a.txt",
            "original_filename"=>"part_a.txt"}],
        "files_uploaded"=>"true",
        "parts_list_uploaded"=>"false",
        "order"=>
          {"stated_experience"=>"",
           "stated_priority"=>"",
           "stated_manufacturing"=>"",
           "units"=>"mm.",
           "order_groups_attributes"=>
            {"0"=>
              {"parts_attributes"=>
                {"0"=>{"name"=>"Part A", "quantity"=>"1", "material"=>"ABS"},
                 "1416014475445"=>{"name"=>"Part B", "quantity"=>"1", "material"=>"unobtanium"},
                 "1416014476543"=>{"name"=>"", "quantity"=>"1", "material"=>""},
                 "1416014479356"=>{"name"=>"", "quantity"=>"1", "material"=>""}}}},
           "deadline"=>"",
           "order_description"=>"",
           "supplier_message"=>""}

      follow_redirect!
      expect(response.body).to include("Order created")

      new_order = Order.last
      expect(new_order.order_groups[0].parts.size).to eq 2
    end

    it "with incompletely filled-out part info, gives validation error message and does not create an order" do
      post "/orders",
        "order_uploads"=>
          [{"url"=>
             "https://s3.amazonaws.com/supplybetter_test_file_upload/externals%2F301-1afbf063116d5041dab5a9d0a8d1bacc%2Fpart_a.txt",
            "original_filename"=>"part_a.txt"}],
        "files_uploaded"=>"true",
        "parts_list_uploaded"=>"false",
        "order"=>
          {"stated_experience"=>"",
           "stated_priority"=>"",
           "stated_manufacturing"=>"",
           "units"=>"mm.",
           "order_groups_attributes"=>
            {"0"=>
              {"parts_attributes"=>
                {"0"=>{"name"=>"Part A", "quantity"=>"1", "material"=>"ABS"},
                 "1416014475445"=>{"name"=>"Part B", "quantity"=>"1", "material"=>""}, 
                 "1416014479356"=>{"name"=>"", "quantity"=>"1", "material"=>"unobtanium"}}}},
           "deadline"=>"",
           "order_description"=>"",
           "supplier_message"=>""}

      expect(response.body).to include("name can&#39;t be blank")
      expect(response.body).to include("material is too short (minimum is 2 characters)")
      expect(Order.all.size).to eq 0
    end

    it "with no parts info filled in, gives validation error message and does not create an order" do
      post "/orders",
        "order_uploads"=>
          [{"url"=>
             "https://s3.amazonaws.com/supplybetter_test_file_upload/externals%2F301-1afbf063116d5041dab5a9d0a8d1bacc%2Fpart_a.txt",
            "original_filename"=>"part_a.txt"}],
        "files_uploaded"=>"true",
        "parts_list_uploaded"=>"false",
        "order"=>
          {"stated_experience"=>"",
           "stated_priority"=>"",
           "stated_manufacturing"=>"",
           "units"=>"mm.",
           "order_groups_attributes"=>
            {"0"=>
              {"parts_attributes"=>
                {"0"=>{"name"=>"", "quantity"=>"1", "material"=>""},
                 "1416014475445"=>{"name"=>"", "quantity"=>"1", "material"=>""}, 
                 "1416014479356"=>{"name"=>"", "quantity"=>"1", "material"=>""}}}},
           "deadline"=>"",
           "order_description"=>"",
           "supplier_message"=>""}

      expect(response.body).to include("Please enter name, quantity, and material for at least one part.")
      expect(Order.all.size).to eq 0
    end

    it "with parts list uploaded, saves order with no parts" do
      post "/orders",
        "order_uploads"=>
          [{"url"=>
             "https://s3.amazonaws.com/supplybetter_test_file_upload/externals%2F301-1afbf063116d5041dab5a9d0a8d1bacc%2Fpart_a.txt",
            "original_filename"=>"part_a.txt"}],
        "files_uploaded"=>"true",
        "parts_list_uploaded"=>"true",
        "order"=>
          {"stated_experience"=>"",
           "stated_priority"=>"",
           "stated_manufacturing"=>"",
           "units"=>"mm.",
           "order_groups_attributes"=>
            {"0"=>
              {"parts_attributes"=>
                {"0"=>{"name"=>"", "quantity"=>"1", "material"=>""}}}},
           "deadline"=>"",
           "order_description"=>"",
           "supplier_message"=>""}

      follow_redirect!
      expect(response.body).to include("Order created")

      new_order = Order.last
      expect(new_order.order_groups[0].parts.size).to eq 0
    end
  end

  describe "New order" do
    it "logs the event when an order is viewed by its owner" do
      user = FactoryGirl.create :user
      order = FactoryGirl.create :order, user: user
      post sessions_path, { :session => { :email => user.lead.lead_contact.email, :password => user.password } }

      get "orders/#{order.id}"

      new_event = Event.last
      expect(new_event.model_id).to eq order.id
      expect(new_event.happening).to eq "order viewed by owner"
    end

    it "logs the event when an order is viewed using the share link" do
      order = FactoryGirl.create :order

      get "orders/view/#{order.id}/#{order.view_token}"

      new_event = Event.last
      expect(new_event.model_id).to eq order.id
      expect(new_event.happening).to eq "order viewed using share link"
    end

    it "does not log an event when an order is viewed by an admin user" do
      order = FactoryGirl.create :order
      admin_user = FactoryGirl.create :admin_user
      post sessions_path, { :session => { :email => admin_user.lead.lead_contact.email, :password => admin_user.password } }

      get "orders/#{order.id}"

      expect(Event.all.size).to eq 0
    end
  end

end
