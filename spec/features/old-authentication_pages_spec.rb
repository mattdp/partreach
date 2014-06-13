require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin page" do
    before { visit signin_path }

    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('div.alert.alert-danger', text: 'Invalid') }

      #describe "after visiting another page" do
      #  before { click_link  }
      #  it { should_not have_selector('div.alert.alert-error') }
      #end

    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.lead.lead_contact.email
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { should have_link('My profile', href: user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users controller" do

        describe "visiting the index page" do
          before { visit orders_path }
          it { should have_selector('h1', text: 'Sign in') }
        end

        describe "submitting PATCH to the update action", type: :request do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to signin_path }
        end

      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email",    with: user.lead.lead_contact.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            page.should have_selector('h1', text: 'Editing user')
          end
        end
      end

    end

    describe "as wrong user", type: :request do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user) }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('h1', text: 'Editing user') }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) }
      end
    end

    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin }

      #no delete action any more, though will have one in future
      describe "submitting a DELETE request to the Users#destroy action", :broken => true do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }        
      end
    end

  end

end