require 'spec_helper'

describe "Tag" do

	before(:each) do 
		@supplier = FactoryGirl.create(:supplier)
		@same_family_tag = FactoryGirl.create(:tag)
		@other_family_tag = FactoryGirl.create(:tag, family: "other")
		@adding_tag = FactoryGirl.build(:tag)
		@supplier.add_tag(@same_family_tag.id)
		@supplier.add_tag(@other_family_tag.id)
	end

	it "should have both tags" do
		@supplier.has_tag?(@same_family_tag.id).should be_true
	end

	describe "exclusive tags" do
		it "should delete other tags in its family when added"
		it "should retain other tags not in its family when added"
	end
	
end