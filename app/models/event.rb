# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  model      :string(255)
#  happening  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Event < ActiveRecord::Base
  attr_accessible :happening, :model
end
