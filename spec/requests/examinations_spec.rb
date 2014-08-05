require "spec_helper"

describe "/examinations requests" do

  before do
    @admin = FactoryGirl.create :admin_user

    # sign in as admin user
    post sessions_path, { :session => { :email => @admin.lead.lead_contact.email, :password => @admin.password } }
  end

  describe "Review examination" do
    before do
      FactoryGirl.create :review
    end

    it "displays the Review Examination page" do
      get "/examinations/review"
      expect(response).to render_template(:_review_examination)
    end
  end

  describe "Supplier search result examination" do
    before do
      @wsr = FactoryGirl.create :web_search_result

      # populate database with needed tags
      exclusive_group = FactoryGirl.create(:tag_group, exclusive: true)
      # new_supplier tags
      @b0_none_sent = FactoryGirl.create(:tag, name: 'b0_none_sent')
      @n1_no_contact = FactoryGirl.create(:tag, name: 'n1_no_contact')
      @e2_existence_unknown = FactoryGirl.create(:tag, name: 'e2_existence_unknown', tag_group: exclusive_group)
      # datadump tag
      @datadump = FactoryGirl.create(:tag, name: 'datadump', tag_group: exclusive_group)
    end

    it "displays the Supplier Search Result Examination page" do
      get "/examinations/supplier_search_result"
      expect(response).to render_template(:_supplier_search_result_examination)
    end

    it "adds chosen supplier as a new supplier" do
      get "/examinations/supplier_search_result"
      post "/examinations",
        "model_examined"=>"supplier_search_result", "name"=>{@wsr.id=>"derived_name"},
        "url_main"=>{@wsr.id=>"http://derived_url.com"}, "choices"=>{@wsr.id=>"add_supplier"}

      expect(response).to redirect_to (setup_examinations_path('supplier_search_result'))
      follow_redirect!
      expect(response.body).to include("Supplier search results submitted")

      new_supplier = Supplier.first
      expect(new_supplier.name).to eq 'derived_name'
      expect(new_supplier.url_main).to eq 'http://derived_url.com'
      expect(new_supplier.source).to eq 'supplier_search_result_examination'
      expect(new_supplier.profile_visible).to be_false
      expect(new_supplier.tags).to match_array([@b0_none_sent, @n1_no_contact, @datadump])
    end
  end

end
