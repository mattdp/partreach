# == Schema Information
#
# Table name: geographies
#
#  id                   :integer          not null, primary key
#  level                :string(255)
#  short_name           :string(255)
#  long_name            :string(255)
#  name_for_link        :string(255)
#  containing_geography :integer
#  created_at           :datetime
#  updated_at           :datetime
#

class Geography < ActiveRecord::Base

end
