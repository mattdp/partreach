class UserMailer < ActionMailer::Base
  default from: "noreply@supplybetter.com",
          bcc: "partreach@gmail.com"
  include SessionsHelper

  MATT =  "matt@supplybetter.com"
  ROB =   "rob@supplybetter.com"
  JAMES = "james@supplybetter.com"
  CUSTOMER_SERVICE = "robert@supplybetter.com"
  INTERNAL_EMAIL_DISTRIBUTION_LIST = [CUSTOMER_SERVICE,MATT,ROB,JAMES]

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

end
