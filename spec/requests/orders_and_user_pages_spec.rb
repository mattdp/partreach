require 'spec_helper'

describe "Order and users" do

	#paralell processes to build these; somewhat brittle, but learned a bunch about factories doing it
	built_orders = FactoryGirl.build_list(:order, 2)
	built_users =  FactoryGirl.build_list(:user, 2)

	describe "basic factory sanity" do # PICK UP HERE
		it "should have the order attached to the correct user" do
			built_orders[0].user.id == built_users[0].id
		end

		it "shouldn't have the order attached to the wrong user" do
			built_orders[1].user.id != built_users[0].id
		end
	end

	describe "destruction: " do
		o = FactoryGirl.create(:order)
		u = o.user

		describe "order should exist before user is destroyed" do
			it { expect { o.quantity }.to_not raise_error }
		end

		describe "order shouldn't exist after user is destroyed" do
			before { u.destroy }
			it { expect { o.quantity }.to raise_error }
		end

	end

end