# == Schema Information
#
# Table name: owners
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  machine_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Owner < ActiveRecord::Base
	attr_accessible :supplier_id, :machine_id

	belongs_to :supplier
	belongs_to :machine

end
