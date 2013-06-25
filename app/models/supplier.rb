# == Schema Information
#
# Table name: suppliers
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  url_main        :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  description     :text
#  email           :string(255)
#  phone           :string(255)
#  url_materials   :string(255)
#  source          :string(255)
#  profile_visible :boolean          default(FALSE)
#  name_for_link   :string(255)
#

class Supplier < ActiveRecord::Base
  attr_accessible :name, :name_for_link, :url_main, :url_materials, :description, :email, :phone, :address_id, :source, :profile_visible

  has_many :dialogues
  has_one :address, :as => :place
  has_many :combos
  has_many :tags, :through => :combos
  has_many :owners
  has_many :machines, :through => :owners

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  def add_tag(tag_id)
    t = Tag.find_by_id(tag_id)    
    return false if t.nil?    
    c = Combo.new(supplier_id: self.id, tag_id: tag_id)
    Combo.destroy_family_tags(self.id,tag_id) if t.exclusive and !t.family.nil?
    return c.save
  end

  def remove_tag(tag_id)
    c = Combo.where("supplier_id = ? AND tag_id = ?", self.id, tag_id)
    Combo.destroy_all(supplier_id: self.id, tag_id: tag_id) unless c.nil?
  end

  def has_tag?(tag_id)
    t = Tag.find_by_id(tag_id)
    return false if t.nil?    
    self.tags.include?(t)
  end

  def add_machine(machine_id)
    m = Machine.find_by_id(machine_id)    
    return false if m.nil?
    w = Owner.new(supplier_id: self.id, machine_id: machine_id) 
    return w.save
  end

  def remove_machine(machine_id)
    w = Owner.where("supplier_id = ? AND machine_id = ?", self.id, machine_id)
    Owner.destroy_all(supplier_id: self.id, machine_id: machine_id) unless w.nil?
  end

  def has_machine?(machine_id)
    m = Machine.find_by_id(machine_id)
    return false if m.nil?
    self.machines.include?(m)
  end 

  def visible_tags
    return nil if self.tags.nil?
    answer = []
    self.tags.each do |t|
      answer << t if t.visible
    end
    return answer
  end

  def self.visible_profiles
    Supplier.where('profile_visible = true')
  end

  def safe_country
    return self.address.country if self.address and self.address.country.present?
    return "no-country"
  end

  def safe_state
    return self.address.state if self.address and self.address.state.present?
    return ""
  end 

  def safe_zip
    return self.address.zip if self.address and self.address.zip.present?
    return ""
  end  

end

#may need to add material and method
