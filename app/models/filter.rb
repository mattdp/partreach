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

  #make sure to add US (country)
  def self.initial_generation
  	us_and_states = Geography.all_us_states.concat([Geography.locate("US",:short_name,"country")])
  	tag_names = ["SLS","SLA","FDM","FFF","3d_printing","custom_machining"]

  	has_not_tag = Tag.find_by_name("datadump")
  	tag_names.each do |t_name|
  		has_tag = Tag.find_by_name(t_name)
  		us_and_states.each do |geography|
  			Filter.create({geography_id: geography.id, has_tag_id: has_tag.id, has_not_tag_id: has_not_tag.id})
  		end
  	end
  end

	def name_formatter
		
	end

end
