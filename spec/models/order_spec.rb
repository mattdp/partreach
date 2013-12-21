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
#  deadline               :string(255)
#  supplier_message       :text
#  recommendation         :text
#  material_message       :text
#  next_steps             :text
#  suggested_suppliers    :text
#  drawing_units          :string(255)
#  status                 :string(255)      default("Needs work")
#  next_action_date       :string(255)
#  stated_experience      :string(255)
#  stated_priority        :string(255)
#  stated_manufacturing   :string(255)
#  notes                  :text
#  override_average_value :decimal(, )
#  columns_shown          :string(255)
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

end
