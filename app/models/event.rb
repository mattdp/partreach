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

  def has_been_touched_by_user?
    happenings = ['said job was good', 'said job was bad', 'said contact me later']
    happenings.include?(self.happening)
  end

  def self.for_user(user)
    Event.where(model: 'User').where(model_id: user.id).order(:created_at)
  end

  def self.hax_happenings
    ["loaded index","loaded profile","attempted comment create for",
      "loaded new comment page for", "edit_providername_from_profile",
      "edit_whatcantheydo_from_profile", "add_po_from_profile",
      "add_visit_from_profile","edit_address_from_profile",
      "edit_contactinfo_from_profile", "searched providers by tags",
      "added comment rating","signed in"
    ]
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

  #takes a date object
  #mysteriously the first email sent doesn't format correctly, so sending it to robert@ rather than one of us
  def self.daily_update_2015(date, admin_reject = true)
    begin_string = date.to_s + " 00:00:00"
    end_string = date.to_s + " 23:59:59"

    content = "<p>Format: each header is USER NAME-ORGANIZATION, and under it are the events the user did that day. This excludes admin actions.</p>"
    content += "<p>This can be improved by having events link to relevant pages; file stories on what links you most need.</p>"

    # # NOT IMPLEMENTED YET
    # address_changes = Event.where("created_at >= ? and created_at < ?",begin_string,end_string)
    # content += "<h2>Address changes - need to manual update</h2>"
    # address_changes.each do |event|
    #   "NOT IMPLEMENTED YET"
    # end

    events = Event.where("created_at >= ? and created_at < ? and model = 'User' and model_id IS NOT NULL",begin_string,end_string).order(:model_id)
    
    if (admin_reject)
      #don't want admin events polluting things
      events = events.reject{|e| (e.model == "User" \
        and User.find(e.model_id).present? \
        and User.find(e.model_id).admin
      )}
    end

    content += "<h1>No non-admin user events today</h1>" if events.count == 0 

    last_model_id = 0
    events.each do |event|
      if last_model_id != event.model_id
        user = User.find(event.model_id)
        organization = user.team.organization if user.team.present?
        contact = user.lead.lead_contact
        if organization.present?
          content += "<h2>#{organization.name} - #{contact.name}</h2>"
        else
          content += "<h2>#{contact.name}</h2>"
        end
      end
      content += "<p>#{event.created_at}: #{event.happening} (#{event.target_model} #{event.target_model_id})</p>"
      last_model_id = event.model_id
    end

    content += "<br>"
    unaffiliated_events = Event.where("created_at >= ? and created_at < ? and model IS NULL",begin_string,end_string)
    if unaffiliated_events.count == 0
      content += "<h1>No user-unaffiliated events today</h1>"
    else
      content += "<h2>User-unaffiliated events"
      unaffiliated_events.each do |event|
        content += "<p>#{event.created_at}: #{event.happening}</p>"
      end
    end

    UserMailer.email_internal_team("#{Rails.env} - Update for activity taking place on #{date.to_s}",content)

    return true
  end

end
