require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "signup" do

    before { visit signup_path }

    let(:submit) { "Create order" }

    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
    end

    describe "with valid information" do
      before do
        fill_in "user_name_field",      with: "Example User"
        fill_in "user_email_field",     with: "user@example.com"
        fill_in "user_password_field",  with: "foobar"
        fill_in "material_message_field", with: "Ossium"
        fill_in "quantity_field",       with: "100"
        find("#direct-upload-file").set "doesnt-test-upload.txt"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      #user getting created, since saves first, but page not progressing
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

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