require "spec_helper"

describe "Provider-based requests" do

  before :each do
    @team_user = FactoryGirl.create :team_user

    # sign in as admin user
    post sessions_path, { :session => { :email => @team_user.lead.lead_contact.email, :password => @team_user.password } }
  end

  describe "Provider index page" do
    visit enterprise_path

    page.should have_content "are using to make parts"
  end

end
