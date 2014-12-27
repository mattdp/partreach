def sign_in(user)
  visit signin_path
  fill_in "Email",    with: user.lead.lead_contact.email
  fill_in "Password", with: user.password
  click_button "Sign in"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

# populate database with predefined tags
def create_tag_sets
  FactoryGirl.create(:tag, name: 'e0_out_of_business')
  FactoryGirl.create(:tag, name: 'e1_existence_doubtful')
  FactoryGirl.create(:tag, name: 'e2_existence_unknown')
  FactoryGirl.create(:tag, name: 'e3_existence_confirmed')

  FactoryGirl.create(:tag, name: 'n1_no_contact')
  FactoryGirl.create(:tag, name: 'n5_signed_only')
  FactoryGirl.create(:tag, name: 'n6_signedAndNDAd')

  FactoryGirl.create(:tag, name: 'b0_none_sent')

  FactoryGirl.create(:tag, name: 'datadump')
end
