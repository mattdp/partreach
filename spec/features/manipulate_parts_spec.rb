require 'spec_helper'

feature "Manipulate parts" do

  before do
    @order = FactoryGirl.create :order

    admin = FactoryGirl.create :admin_user
    #sign_in admin
    visit signin_path
    fill_in "Email",    with: admin.lead.lead_contact.email
    fill_in "Password", with: admin.password
    click_button "Sign in"

    visit manipulate_parts_path(@order)
  end

  scenario "Saving without making any changes shouldn't do any updates" do
    page.click_button "Save changes"
    # TBD
  end

end