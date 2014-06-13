require 'spec_helper'

feature "Login and redirection" do
  before :each do
    @user = FactoryGirl.create(:user)
    @order = FactoryGirl.create(:order, user: @user)
  end

  scenario "Visiting orders as not-signed-in user should be blocked, then permitted after signup" do
    visit orders_path
    page.should have_content "Please sign in."

    page.fill_in "session_email", with: @user.lead.lead_contact.email
    page.fill_in "session_password", with: @user.password
    page.click_button "Sign in"

    page.should have_content @order.deadline
  end

end