# == Schema Information
#
# Table name: order_groups
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  process    :string(255)
#

class OrderGroup < ActiveRecord::Base

	belongs_to :order
	has_many :parts, dependent: :destroy
	has_many :dialogues

  validates :name, presence: true

  def self.switch_group_of_parts(to_group_id,part_array)
  	part_array.each do |part|
  		part.order_group_id = to_group_id
  		if part.save
  			puts "Part #{part.id} switched to group #{to_group_id}"
  		else
  			puts "Error switching part #{part.id}"
  		end
  	end
	end

end
