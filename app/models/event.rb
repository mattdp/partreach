# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  model      :string(255)
#  happening  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  model_id   :integer
#

class Event < ActiveRecord::Base

  def self.add_event(model,model_id,happening)
  	event = Event.new(model: model, happening: happening)
 		return event.save
  end

end
