# == Schema Information
#
# Table name: orders
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :integer
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
#  status                 :string(255)      default("Needs work")
#  next_action_date       :string(255)
#  stated_experience      :string(255)
#  stated_priority        :string(255)
#  stated_manufacturing   :string(255)
#  notes                  :text
#  override_average_value :decimal(, )
#  columns_shown          :string(255)      default("all")
#

require 'spec_helper'

describe "Order" do
	
	before do
		@order = Order.new(material_message: "made of grapes")
	end

	subject { @order }

	describe "when user is not attached to order" do
		before { @order.user_id = nil }
		it { should_not be_valid }
	end
	
end
