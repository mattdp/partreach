require 'spec_helper'

describe 'OrderTransferor' do

  before :each do
    @order = FactoryGirl.create(:order)
  end

  describe 'when a User exists for provided email' do
    before do
      @new_user = FactoryGirl.create(:user)
      @new_user.lead.lead_contact.email = 'test@test.com'
      @new_user.lead.lead_contact.save
      
    end

    it 'assigns the order to the User' do
      OrderTransferor.new(@order).transfer('test@test.com', 'Test User')
      @order.user_id.should == @new_user.id
      @order.user.lead.lead_contact.full_name_untrusted.should_not == 'Test User'
    end

    it 'does not create a new User' do
      expect {OrderTransferor.new(@order).transfer('test@test.com', 'Test User')}.to_not change{User.count}.by(1)
    end
  end

  describe 'when a User does not exist for provided email' do

    it 'creates a new user with that email' do 
      expect {OrderTransferor.new(@order).transfer('test@test.com', 'Test User')}.to change{User.count}.by(1)
      @order.user.lead.lead_contact.email.should == 'test@test.com'
      @order.user.lead.lead_contact.full_name_untrusted.should == 'Test User'
    end

  end


end