require 'spec_helper'

feature "Enterprise landing page" do
  scenario "should load" do
    visit enterprise_path

    page.should have_content "He pays attention to detail"
  end

  scenario "should collect emails" do
    visit enterprise_path

    page.fill_in "session_email", with: @user.lead.lead_contact.email
    page.click_button "Sign in"

    
  end
end