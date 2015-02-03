# == Schema Information
#
# Table name: search_exclusions
#
#  id         :integer          not null, primary key
#  domain     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class SearchExclusion < ActiveRecord::Base
end
