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

  belongs_to :supplier
  belongs_to :machine

end
