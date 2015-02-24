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
#  info            :text
#

class Event < ActiveRecord::Base

  def self.for_user(user)
    Event.where(model: 'User').where(model_id: user.id).order(:created_at)
  end

  def self.hax_happenings
    ["loaded index","loaded profile","attempted comment create for",
      "loaded new comment page for", "edit_providername_from_profile",
      "edit_whatcantheydo_from_profile", "add_po_from_profile",
      "add_visit_from_profile","edit_address_from_profile",
      "edit_contactinfo_from_profile", "searched providers by tags"]
  end

  # happenings: an array of strings
  # start_date/end_date: strings in the form '2015-02-10'
  def self.in_date_range(happenings, start_date, end_date)
    start_datetime = DateTime.parse(start_date)
    end_datetime = DateTime.parse(end_date)
    Event.
      where(happening: happenings).
      where(created_at: (start_datetime)..(end_datetime + 1)).
      where(model: 'User').where.not(model_id: User.select(:id).where(admin: true))
  end

  def self.add_event(model, model_id, happening, target_model=nil, target_model_id=nil, info=nil)
    event = Event.new(model: model, model_id: model_id, happening: happening,
                      target_model: target_model, target_model_id: target_model_id,
                      info: info)
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
