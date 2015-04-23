class PasswordResetsController < ApplicationController
  skip_before_action :allow_staging_access, only: [:new, :create]
  
  def new
    @message_text = "You will receive an email with instructions on how to reset your password"
    render layout: "provider"
  end

  def create
    lead_contact = LeadContact.find_by_email(params[:email])
    if lead_contact 
      user = lead_contact.contactable.user
      user.send_password_reset if user
      @message_text = "An email has been sent with password reset instructions."
    else
      @message_text = "Sorry, we can't locate that email address in our system."
    end
    render "new", layout: "provider"
  end

end
