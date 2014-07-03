require 'spec_helper'

feature "Order creation" do
  before :each do
    @existing_user = FactoryGirl.create(:user)
    @visible_supplier = FactoryGirl.create(:supplier)
  end

  scenario "Creating order without fillout shouldn't make an order" do
    visit new_order_path

    page.click_button "Create order"
    page.should have_content "prohibited this order from being saved"
  end

  #might be something about clearing email queue when done, railscast on testing?
  scenario "Person should be able to create order, saving user and order, we should get an email about it", \
  broken: true do
    visit new_order_path

    fill_in "quantity", with: 5
    fill_in "material_message", with: "testonium"
    fill_in "drawing_units", with: "mm"
    fill_in "user_name", with: "Gerald Ford"
    fill_in "user_email", with: "gford@fake.com"
    fill_in "user_password", with: "potuss"
    page.click_button "Create order"
    
    #PICK UP AND DEBUG HERE

    #order should be created
    #save_and_open_page
    page.should have_content "Details of quote request"

    #user should be saved
    #they should be taken to appropriate page
    #we should get an email about it

  end

  scenario "Clicking create off supplier page and selecting options should lead to correct options on final page", broken: true do
    visit supplier_profile_path(@visible_supplier.name_for_link)
    page.should have_content "Request Quote"
    page.click_on "Request Quote"

    page.should have_content "Help us ask you the right questions"
    find(:css,"#questions_experience_experienced").set(true)
    page.click_button "Final step"

    page.should have_content "I am experienced"
    page.should have_content "Include #{@visible_supplier.name}"
  end

end