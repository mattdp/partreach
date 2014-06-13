require 'spec_helper'

#AS DONE CURRENTLY, THIS FILE POLLUTES THE TEST DB
#before or before each, in commented out section, fails tests since created_orders doesn't seem to exist

describe "Order and users" do

  describe "lack of orders", type: :request do
    let(:user) { FactoryGirl.create(:user) }
    subject { page }

    before do 
      sign_in user
      visit orders_path
    end

    it { should have_selector('p', text: 'No orders') }
  end

  #paralell processes to build these; somewhat brittle, but learned a bunch about factories doing it

  # created_orders = FactoryGirl.create_list(:order, 2)
  # created_users =  FactoryGirl.create_list(:user, 2)

  # describe "basic factory sanity" do # PICK UP HERE

  #   it "should have the order attached to the correct user" do
  #     created_orders[0].user.id == created_users[0].id
  #   end

  #   it "shouldn't have the order attached to the wrong user" do
  #     created_orders[1].user.id != created_users[0].id
  #   end
  # end

end