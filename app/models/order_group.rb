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
	has_many :dialogues, dependent: :destroy

  validates :name, presence: true

  def email_snippet_generator
    snippet = "<p><u><strong>#{self.name} (Process: #{self.process}, Material: #{self.material})</strong></u></p>\n"
    snippet += "<ul>\n"
    self.parts.each do |part|
      external = part.external
      snippet += "<li>\n#{part.name}, quantity #{part.quantity}"
      if external
        snippet += " (<a href=#{external.url}>Link to drawing</a>"
        snippet += ", drawing units: #{external.units})\n"
      end
      snippet += "</li>\n"
    end
    snippet += "</ul>\n"
    return snippet
  end

  def self.switch_group(to_group_id,model_array)
  	model_array.each do |model|
  		model.order_group_id = to_group_id
  		if model.save
  			puts "#{model.class.to_s} #{model.id} switched to group #{to_group_id}"
  		else
  			puts "Error switching #{model.class.to_s} #{model.id}"
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
