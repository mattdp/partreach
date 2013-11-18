require 'spec_helper'

feature "Login and redirection" do
	background do
		user = FactoryGirl.create(:user)
	end

	scenario "Attemping to visit link with signin required should be blocked" do
		visit orders_path
	end

end