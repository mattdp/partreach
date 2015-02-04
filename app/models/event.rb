# == Schema Information
#
# Table name: events
#
#  id              :integer          not null, primary key
#  model           :string(255)
#  happening       :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  model_id        :integer
#  target_model    :string(255)
#  target_model_id :integer
#

class Event < ActiveRecord::Base

  def self.add_event(model,model_id,happening,target_model=nil,target_model_id=nil)
    event = Event.new(model: model, model_id: model_id, happening: happening, target_model: target_model, target_model_id: target_model_id)
    return event.save
  end

  def self.has_event?(model,model_id,happening)
    Event.where("model = ? and model_id = ? and happening = ?",model,model_id,happening).present?
  end

  def self.order_closed_events(start_date, end_date)
    Event.where(
      "created_at >= ? AND created_at < ? AND model = ? AND happening = ?",
      start_date, end_date, "Order", "closed_successfully")
  end

end
