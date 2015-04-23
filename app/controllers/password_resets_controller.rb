class PasswordResetsController < ApplicationController
  skip_before_action :allow_staging_access, only: [:new, :create]
  
  def new
    render layout: "provider"
  end

  def create
    lead_contact = LeadContact.find_by_email(params[:email])
    if lead_contact 
      user = lead_contact.contactable.user
      user.send_password_reset if user
    end
    redirect_to teams_signin_url, :notice => "Email sent with password reset instructions."
  end

end
