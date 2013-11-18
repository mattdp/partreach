require 'spec_helper'

feature "Order creation" do
	background do
		@existing_user = FactoryGirl.create(:user)
	end

	scenario "Creating order without fillout shouldn't make an order" do
		visit new_order_path

		page.click_button "Create order"
		page.should have_content "too short"
	end

	#might be something about clearing email queue when done, railscast on testing?
	scenario "Person should be able to create order, saving user and order, we should get an email about it", broken: true do
		visit new_order_path

		fill_in "quantity_field", with: 5
		fill_in "material_message_field", with: "testonium"
		fill_in "drawing_units_field", with: "mm"
		fill_in "user_name_field", with: "Gerald Ford"
		fill_in "user_email_field", with: "gford@fake.com"
		fill_in "user_password_field", with: "potuss"
		page.click_button "Create order"
		
		#PICK UP AND DEBUG HERE

		#order should be created
		page.should have_content "Details of quote request"

		#user should be saved
		#they should be taken to appropriate page
		#we should get an email about it

	end

end