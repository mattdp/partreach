class SessionsController < ApplicationController

  def new
  end

  def create
    lead_contact = LeadContact.find_by_email(params[:session][:email].downcase)
    if (lead_contact and user = lead_contact.contactable.user and user.authenticate(params[:session][:password]))
      sign_in user
      redirect_back_or orders_path
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

end
