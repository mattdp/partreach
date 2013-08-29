require 'spec_helper'

describe "Supplier-related pages" do

	subject {page}	

	describe "Supplier index" do

		before do
			visit suppliers_path
		end

		it "should load correctly" do
			should have_link("Home")
		end
	end

	describe "Be a Supplier page" do
		before do
			visit be_a_supplier_path
		end

		it "should load correctly" do
			should have_link("Home")
		end
	end

	describe "Supplier editing pages" do

		before(:each) do
      @supplier = FactoryGirl.create(:supplier)
      @non_supplier_linked_user = FactoryGirl.create(:user)
      @supplier_linked_user = FactoryGirl.create(:user, :supplier_id => @supplier.id)
    end

		describe "supplier-linked users", :broken => true do
			before do
    		sign_in @supplier_linked_user
    		visit orders_path
    	end

			it "should have the option to edit supplier profiles" do
				should have_link("edit the supplier profile")
			end
		end

		describe "non supplier-linked users" do
			before do
    		sign_in @non_supplier_linked_user
    		visit orders_path
    	end

			it "should not have the option to edit supplier profiles" do
				should_not have_link("edit the supplier profile")
			end		
		end
	end

end