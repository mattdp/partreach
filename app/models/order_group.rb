# == Schema Information
#
# Table name: order_groups
#
#  id            :integer          not null, primary key
#  order_id      :integer
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  process       :string(255)
#  material      :string(255)
#  email_snippet :text
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

  def visible_dialogues
    visibles = []
    self.dialogues.map{|d| visibles << d if d.opener_sent}
    return visibles
  end

  def sort_visible_dialogues
    # should be: 
    # recommended, in nonzero low to high
    # completed, in nonzero low to high
    # declined, alphabetical
    # pending, alphabetical
    answer = []

    recommended = []
    completed = []
    declined = []
    pending = []

    self.visible_dialogues.each do |d|
      if d.recommended
        recommended << d 
      elsif d.bid?
        completed << d
      elsif d.declined?
        declined << d
      else
        pending << d
      end
    end

    [recommended, completed, declined, pending].each do |piece|
      answer.concat piece.sort_by! { |m| Supplier.find(m.supplier_id).name.downcase }
    end

    return answer
  end    

end
