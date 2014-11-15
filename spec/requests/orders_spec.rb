require "spec_helper"

describe "/orders requests" do

  before do
    @user = FactoryGirl.create :admin_user

    # sign in as registered user
    post sessions_path, { :session => { :email => @user.lead.lead_contact.email, :password => @user.password } }
  end

  describe "New order" do
    it "creates a new order with valid input" do
      post "/orders",
        "uploads"=>
          [{"url"=>
             "https://s3.amazonaws.com/supplybetter_test_file_upload/externals%2F301-1afbf063116d5041dab5a9d0a8d1bacc%2Fpart_a.txt",
            "original_filename"=>"part_a.txt"}],
        "files_uploaded"=>"true",
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
           "order_description"=>"",
           "supplier_message"=>""}

      follow_redirect!
      expect(response.body).to include("Order created")

      new_order = Order.last
      expect(new_order.order_groups[0].parts.size).to eq 1
    end

    it "discards blank part rows and creates a new order" do
      post "/orders",
        "uploads"=>
          [{"url"=>
             "https://s3.amazonaws.com/supplybetter_test_file_upload/externals%2F301-1afbf063116d5041dab5a9d0a8d1bacc%2Fpart_a.txt",
            "original_filename"=>"part_a.txt"}],
        "files_uploaded"=>"true",
        "order"=>
          {"stated_experience"=>"",
           "stated_priority"=>"",
           "stated_manufacturing"=>"",
           "units"=>"mm.",
           "order_groups_attributes"=>
            {"0"=>
              {"parts_attributes"=>
                {"0"=>{"name"=>"Part A", "quantity"=>"1", "material"=>"ABS"},
                 "1416014475445"=>{"name"=>"", "quantity"=>"1", "material"=>""}, 
                 "1416014479356"=>{"name"=>"", "quantity"=>"1", "material"=>""}}}},
           "deadline"=>"",
           "order_description"=>"",
           "supplier_message"=>""}

      follow_redirect!
      expect(response.body).to include("Order created")

      new_order = Order.last
      expect(new_order.order_groups[0].parts.size).to eq 1
    end

    it "gives validation error message and does not create an order, with incompletely filled-out part info" do
      post "/orders",
        "uploads"=>
          [{"url"=>
             "https://s3.amazonaws.com/supplybetter_test_file_upload/externals%2F301-1afbf063116d5041dab5a9d0a8d1bacc%2Fpart_a.txt",
            "original_filename"=>"part_a.txt"}],
        "files_uploaded"=>"true",
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
  end

end
