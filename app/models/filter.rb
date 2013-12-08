# == Schema Information
#
# Table name: filters
#
#  id             :integer          not null, primary key
#  geography_id   :integer
#  has_tag_id     :integer
#  has_not_tag_id :integer
#  name           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Filter < ActiveRecord::Base

  belongs_to :geography
  belongs_to :has_tag, class_name: 'Tag'
  belongs_to :has_not_tag, class_name: 'Tag'

  validates :name, presence: true, uniqueness: {case_sensitive: false}
  validates_presence_of :geography
  validates_presence_of :has_tag

  #make sure to add US (country)
  def self.initial_generation
  	us_and_states = Geography.all_us_states.concat([Geography.locate("US",:short_name,"country")])
  	tag_names = ["SLS","SLA","FDM","FFF","3d_printing","custom_machining"]

  	has_not_tag = Tag.find_by_name("datadump")
  	tag_names.each do |t_name|
  		has_tag = Tag.find_by_name(t_name)
  		us_and_states.each do |geography|
  			f = Filter.new({geography_id: geography.id, has_tag_id: has_tag.id, has_not_tag_id: has_not_tag.id})
  			f.name = f.name_formatter
  			f.save
  		end
  	end
  end

	def name_formatter
		geo = self.geography
		phrase = "#{geo.name_for_link}-#{self.has_tag.name_for_link}"
		containing_geo = geo.get_containing_geography
		phrase = "#{containing_geo.name_for_link}-#{phrase}" if containing_geo
		return phrase
	end

end
