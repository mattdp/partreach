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

  belongs_to :supplier
  belongs_to :tag

  validates_uniqueness_of :supplier_id, scope: :tag_id

  def self.destroy_family_tags(supplier_id, tag_id)
  	family = Tag.find(tag_id).family
  	removees = Tag.return_family_ids(family)
  	Combo.find_each do |c|
  		c.destroy if c.supplier_id == supplier_id and removees.include?(c.tag_id)
  	end
  end

end
