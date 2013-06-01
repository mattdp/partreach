require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup" do

    before(:each) do
      @supplier = FactoryGirl.create(:supplier)
      @saved_user = FactoryGirl.create(:user)
      @new_user = User.new(name: "NewUser", email: "newuser@fakemail.com", password: "newuser")
    end

    before do 
      visit signup_path
    end

    let(:submit) { "Create order" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "material_message_field", with: "Ossium"
        fill_in "quantity_field",       with: "100"
        fill_in "drawing_units_field",        with: "mm"
        find("#direct-upload-file").set "doesnt-test-upload.txt"
      end

      describe "for a new user" do
        before do 
          fill_in "user_name_field",      with: @new_user.name
          fill_in "user_email_field",     with: @new_user.email
          fill_in "user_password_field",  with: @new_user.password
        end
      
        it "should have at least some link visible" do
          should have_link("Back to orders")
        end

        it "should have a visible file confirmation, or other tests will fail" do
          should have_selector('#direct-upload-file', visible: true)
        end

        it "should create a user" do
          expect { click_button submit }.to change(User, :count).by(1)
        end
      end

      describe "for an existing user" do
        before do
          fill_in "signin_email_field",     with: @saved_user.email
          fill_in "signin_password_field",  with: @saved_user.password
        end

        #user getting created, since saves first, but page not progressing
        describe "after saving the user" do
          before { click_button submit }

          it { should have_selector('h1', text: 'My requests for quotes') }
          it { should have_link ('Sign out') }

          describe "followed by signout" do
            before { click_link 'Sign out' }
            it { should have_link('Sign in') }
          end
        end
      end

    end
  end

end