# == Schema Information
#
# Table name: combos
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  tag_id      :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Combo < ActiveRecord::Base
  attr_accessible :supplier_id, :tag_id
end
