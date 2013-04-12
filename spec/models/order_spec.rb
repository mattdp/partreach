# == Schema Information
#
# Table name: orders
#
#  id                     :integer          not null, primary key
#  quantity               :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :integer
#  drawing_file_name      :string(255)
#  drawing_content_type   :string(255)
#  drawing_file_size      :integer
#  drawing_updated_at     :datetime
#  name                   :string(255)
#  deadline               :date
#  supplier_message       :text
#  is_over_without_winner :boolean
#  recommendation         :string(255)
#  material_message       :text
#  next_steps             :text
#  suggested_suppliers    :string(255)
#

require 'spec_helper'

describe "Order" do
	
	before do
		@order = Order.new(quantity: 151, material_message: "made of grapes")
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
