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
  attr_accessible :happening, :model, :model_id

  def self.add_event(model,model_id,happening)
  	event = Event.new(model: model, happening: happening)
 		return event.save
  end

end
