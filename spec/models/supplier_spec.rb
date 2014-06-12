require 'spec_helper'

describe "Supplier" do

	before :each do 
		@supplier = FactoryGirl.create(:supplier)
		@same_family_tag = FactoryGirl.create(:tag)
		@other_family_tag = FactoryGirl.create(:tag, family: "other")
		@adding_exclusive_tag = FactoryGirl.create(:tag, exclusive: true)
		@supplier.add_tag(@same_family_tag.id)
		@supplier.add_tag(@other_family_tag.id)
	end

	it "should have both tags" do
		@supplier.has_tag?(@same_family_tag.id).should be_true
	end

	describe "exclusive tags" do
		before { @supplier.add_tag(@adding_exclusive_tag.id) }
		it "should delete other tags in its family when added" do
			@supplier.has_tag?(@same_family_tag.id).should be_false
		end
		it "should retain other tags not in its family when added" do
			@supplier.has_tag?(@other_family_tag.id).should be_true
		end
	end

	describe "double tags" do
		before { @supplier.add_tag(@adding_exclusive_tag.id) }
		it "should return false when attempting to re-add a tag" do
			@supplier.add_tag(@adding_exclusive_tag.id).should be_false
		end
	end
	
end
