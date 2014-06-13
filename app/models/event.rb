# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  model      :string(255)
#  happening  :string(255)
#  created_at :datetime
#  updated_at :datetime
#  model_id   :integer
#

class Event < ActiveRecord::Base

  def self.add_event(model,model_id,happening)
    event = Event.new(model: model, model_id: model_id, happening: happening)
    return event.save
  end

  def self.has_event?(model,model_id,happening)
    Event.where("model = ? and model_id = ? and happening = ?",model,model_id,happening).present?
  end

end
