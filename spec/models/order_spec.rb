require 'spec_helper'

describe "Order" do
	
	before do
		@order = Order.new(quantity: 151)
	end

	subject { @order }

	describe "when user is not attached to order" do
		before { @order.user_id = nil }
		it { should_not be_valid }
	end

	describe "quantity should not be negative" do
		before { @order.quantity = -5 }
		it { should_not be_valid }
	end

	describe "accessible attributes" do
		it "should not allow access to user_id" do
			expect do
				Order.new(user_id: @order.id)
			end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
		end
	end

end