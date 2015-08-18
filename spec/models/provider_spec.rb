require 'spec_helper'

describe "Provider" do

	it "allows different orgs to have the same supplier" do
		@org1 = FactoryGirl.create(:organization)
		@org2 = FactoryGirl.create(:organization)
		@same_name = "samename"
		@same_name_for_link = "sname"

    @provider1 = FactoryGirl.create(:provider, name: @same_name, 
    	name_for_link: @same_name_for_link, organization: @org1)
    @provider2 = FactoryGirl.create(:provider, name: @same_name, 
    	name_for_link: @same_name_for_link, organization: @org2)
    @provider1.name.should == @provider2.name
  end

end