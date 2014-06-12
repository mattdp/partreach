require 'spec_helper'

describe "Supplier" do

	before :each do 
		tag_group_1 = FactoryGirl.create(:tag_group, exclusive: true)
		@tag1a = FactoryGirl.create(:tag, tag_group: tag_group_1)
		@tag1b = FactoryGirl.create(:tag, tag_group: tag_group_1)
		tag_group_2 = FactoryGirl.create(:tag_group)
		@tag2 = FactoryGirl.create(:tag, tag_group: tag_group_2)
		@supplier = FactoryGirl.create(:supplier)
		@supplier.add_tag(@tag1a.id)
		@supplier.add_tag(@tag2.id)
	end

	it "can have tags added from different tag groups" do
		@supplier.has_tag?(@tag1a.id).should be_true
		@supplier.has_tag?(@tag2.id).should be_true
	end

	describe "exclusive tags" do
		before { @supplier.add_tag(@tag1b.id) }
		it "should delete other tags in its family when added" do
			@supplier.has_tag?(@tag1a.id).should be_false
		end
		it "should retain other tags not in its family when added" do
			@supplier.has_tag?(@tag2.id).should be_true
		end
	end

	describe "double tags" do
		before { @supplier.add_tag(@tag1b.id) }
		it "should return false when attempting to re-add a tag" do
			@supplier.add_tag(@tag1b.id).should be_false
		end
	end
	
end
