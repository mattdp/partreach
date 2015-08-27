# == Schema Information
#
# Table name: providers
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  url_main                   :string(255)
#  source                     :string(255)      default("manual")
#  name_for_link              :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  contact_qq                 :string(255)
#  contact_wechat             :string(255)
#  contact_phone              :string(255)
#  contact_email              :string(255)
#  contact_name               :string(255)
#  contact_role               :string(255)
#  verified                   :boolean          default(FALSE)
#  city                       :string(255)
#  location_string            :text
#  id_within_source           :integer
#  contact_skype              :string(255)
#  organization_id            :integer          not null
#  organization_private_notes :text
#  external_notes             :text
#  import_warnings            :text
#  supplybetter_private_notes :text
#  name_in_purchasing_system  :string(255)
#

require 'spec_helper'

describe "Provider" do

	it "allows different orgs to have the same supplier" do
		@org1 = FactoryGirl.create(:organization)
		@org2 = FactoryGirl.create(:organization)
		@same_name = "samename"
		@same_name_for_link = "sname"

		#should allow different orgs to have same provider name and n_f_l
    @provider1 = FactoryGirl.create(:provider, name: @same_name, 
    	name_for_link: @same_name_for_link, organization: @org1)
    @provider2 = FactoryGirl.create(:provider, name: @same_name, 
    	name_for_link: @same_name_for_link, organization: @org2)
    @provider1.name.should == @provider2.name

    #should error on same provider
    expect {
    	FactoryGirl.create(:provider, name: @same_name, 
    	name_for_link: @same_name_for_link, organization: @org1)
    }.to raise_error
  end

end
