# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  admin                  :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  address_id             :integer
#  password_digest        :string(255)
#  remember_token         :string(255)
#  password_reset_token   :string(255)
#  password_reset_sent_at :datetime
#  examiner               :boolean          default(FALSE)
#  supplier_id            :integer
#  team_id                :integer
#

require 'spec_helper'

describe "User" do

  before :each do
    @user = FactoryGirl.create(:user)
    @lead_contact = @user.lead.lead_contact
  end

  subject { @user }

  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    let(:found_user) { LeadContact.find_by_email(@lead_contact.email).contactable.user }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }
      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should be_invalid }
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  # currently, not testing email validity, but these should be of use later

  # describe "when email format is invalid" do
  #   it "should be invalid" do
  #     addresses = %w[user@foo,com user_at_foo.org example.user@foo.
  #                    foo@bar_baz.com foo@bar+baz.com]
  #     addresses.each do |invalid_address|
  #       @user.email = invalid_address
  #       @user.should_not be_valid
  #     end      
  #   end
  # end

  # describe "when email format is valid" do
  #   it "should be valid" do
  #     addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
  #     addresses.each do |valid_address|
  #       @user.email = valid_address
  #       @user.should be_valid
  #     end      
  #   end
  # end

  # describe "when email address is already taken" do
  #   before do
  #     user_with_same_email = @user.dup
  #     user_with_same_email.email = @user.email.upcase
  #     user_with_same_email.save
  #   end
  #   it { should_not be_valid }
  # end

end
