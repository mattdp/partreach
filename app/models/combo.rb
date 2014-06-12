# == Schema Information
#
# Table name: combos
#
#  id          :integer          not null, primary key
#  supplier_id :integer
#  tag_id      :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Combo < ActiveRecord::Base

  belongs_to :supplier
  belongs_to :tag

  validates_uniqueness_of :supplier_id, scope: :tag_id

  def self.destroy_family_tags(supplier_id, tag_id)
  	tag_group_id = Tag.find(tag_id).tag_group_id
  	removees = Tag.return_family_ids(tag_group_id)
  	Combo.find_each do |c|
  		c.destroy if c.supplier_id == supplier_id and removees.include?(c.tag_id)
  	end
  end

end
