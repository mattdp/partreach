require "spec_helper"

describe "/examinations requests" do

  before do
    @admin = FactoryGirl.create :admin_user

    # sign in as admin user
    post sessions_path, { :session => { :email => @admin.lead.lead_contact.email, :password => @admin.password } }
  end

  describe "reviews" do

    before do
      @review = FactoryGirl.create :review
    end

    it "displays the Review Examination page" do
      get "/examinations/reviews"
      response.should render_template(:setup_examinations)
      response.body.should include "review"
      p response.body
    end

  end

end
