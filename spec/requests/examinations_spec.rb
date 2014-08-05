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
      response.should render_template(:_review_examination)
    end
  end

  describe "Supplier search result examination" do
    before do
      FactoryGirl.create :web_search_result
    end

    it "displays the Supplier Search Result Examination page" do
      get "/examinations/supplier_search_result"
      response.should render_template(:_supplier_search_result_examination)
    end
  end

end
