class UserMailer < ActionMailer::Base
  default from: "noreply@supplybetter.com",
          bcc: "partreach@gmail.com"
  include SessionsHelper

  MATT =  "matt@supplybetter.com"
  ROB =   "rob@supplybetter.com"
  JAMES = "james@supplybetter.com"
  CUSTOMER_SERVICE = "robert@supplybetter.com"
  INTERNAL_EMAIL_DISTRIBUTION_LIST = [MATT,ROB,JAMES,CUSTOMER_SERVICE]

  def email_internal_team(subject, note)
    @note = note
    INTERNAL_EMAIL_DISTRIBUTION_LIST.each do |e|
      mail(to: e, subject: subject).deliver do |format|
        format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: nil} 
                            }
      end
    end
  end

  #takes a date object
  def daily_update_2015(date)
    begin_string = date.to_s + " 00:00:00"
    end_string = date.to_s + " 23:59:59"

    content = ""

    # # NOT IMPLEMENTED YET
    # address_changes = Event.where("created_at >= ? and created_at < ?",begin_string,end_string)
    # content += "<h2>Address changes - need to manual update</h2>"
    # address_changes.each do |event|
    #   "NOT IMPLEMENTED YET"
    # end

    events = Event.where("created_at >= ? and created_at < ? and model = 'User' and model_id IS NOT NULL",begin_string,end_string).order(:model_id)
    #don't want admin events polluting things
    events.reject{|e| (e.model == "User" \
      and User.find(e.model_id).present? \
      and User.find(e.model_id).admin
    )}

    last_model_id = 0
    events.each do |event|
      if last_model_id != event.model_id
        user = User.find(event.model_id)
        organization = user.team.organization
        contact = user.lead.contact
        content += '<h2><%= "#{organization.name} - #{contact.name}" %></h2>'
      end
      content += '<p><%= "#{event.happening}" %></p>'
      last_model_id = event.model_id
    end

    email_internal_team("Update for activity taking place on #{date.to_s}",content)
  end

  def welcome_email(user)
    @user = user
    @brand_name = brand_name
    subject = "Welcome to #{brand_name}!"
    mail(to: @user.lead.lead_contact.email, subject: subject) do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: nil} 
                            }
      format.text
    end
  end

  #VET THIS - think it's broken
  # def bid_completed_email(user,order)
  #   @user = user
  #   @order = order
  #   @url = orders_path(order)
  #   mail(to: @user.email, subject: "Your #{brand_name} quotes have arrived")
  # end

  def password_reset(user)
    @user = user
    @brand_name = brand_name
    subject = "Password reset requested"
    mail(to: @user.lead.lead_contact.email, subject: subject) do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: nil} 
                            }
      format.text
    end
  end

  def supplier_intro_email(user,supplier)
    @user = user
    @brand_name = brand_name
    @supplier = supplier
    subject = "Your new #{brand_name} account"
    mail(to: @user.lead.lead_contact.email, subject: subject) do |format|
      format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: supplier} 
                            }
      format.text
    end
  end

end
