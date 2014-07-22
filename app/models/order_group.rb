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
#  parts_snippet :text
#  images_snippet :text
#

class OrderGroup < ActiveRecord::Base

  belongs_to :order
  has_many :parts, dependent: :destroy
  has_many :dialogues, dependent: :destroy

  validates :name, presence: true

  def self.create_default
    OrderGroup.create!({name: "Default"})
  end

  def parts_snippet_generator
    snippet = <<-HTML
<p><u><strong>#{name} (Process: #{process}, Material: #{material})</strong></u></p>
<p><strong>Download link for all files:</strong> <a href="ZIPFILELINK]"> <strong>ZIPFILENAME]</strong></a></p>
<p><strong>Total Quantity: </strong>TOTALQUANTITY</p>

<p>Please quote the items below individually.</p>
    HTML

    self.parts.each do |part|
      external = part.external
      next if external.nil?
      suffix = external.url.split(".").last.upcase
      next if suffix.in? ["PNG", "JPG", "ZIP"]
      part_name_without_suffix = part.name.slice(0, part.name.rindex("."))

      snippet += <<-HTML
<ul>
<li><strong>Part: </strong>#{part_name_without_suffix} (<a href=#{external.url}><strong>Link to #{suffix} file</strong></a>)</li>
<li><strong>Quantity: </strong>QUANTITY</li>
<li><strong>Color: </strong>COLOR</li>
<li><strong>Desired method: </strong>METHOD</li>
<li><strong>Drawing units: </strong>UNITS</li>
</ul>
      HTML
    end

    snippet
  end

  def images_snippet_generator
    snippet = ""
    self.parts.each do |part|
      external = part.external
      next if external.nil?
      suffix = external.url.split(".").last.upcase
      if suffix.in? ["PNG", "JPG"]
        snippet += <<-HTML
<p><a href="#{external.url}" alt="SupplyBetter RFQ#{order_id}" target="_blank">
<img src="#{external.url}" alt="SupplyBetter RFQ#{order_id}" width="460"></a></p>
        HTML
      end
    end

    snippet
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

  def alphabetical_dialogues
    dialogues = self.dialogues
    return nil unless dialogues
    return dialogues.sort_by{|dialogue| Supplier.find(dialogue.supplier_id).name.downcase}
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
