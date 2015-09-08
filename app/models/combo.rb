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

  belongs_to :supplier
  belongs_to :tag

  validates_uniqueness_of :supplier_id, scope: :tag_id

end
