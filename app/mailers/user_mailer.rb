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

  def daily_internal_update
    rfqs_created = 1
    rfqs_closed = 2
    quote_value = 3

    metrics_data = Order.metrics(:months,Date.new(2013,8,3))[:printout][0]

    subject = "#{metrics_data[rfqs_created]} RFQs created, #{metrics_data[rfqs_closed]} RFQs closed, $#{metrics_data[quote_value].to_i} quote value"

    INTERNAL_EMAIL_DISTRIBUTION_LIST.each do |e|
      mail(to: e, subject: subject).deliver do |format|
        format.html { render layout: "layouts/blast_mailer", 
                    locals: { title: subject, 
                              supplier: nil} 
                            }
      end
    end
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
