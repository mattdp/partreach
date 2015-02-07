class SessionsController < ApplicationController

  def new
  end

  def create
    lead_contact = LeadContact.find_by_email(params[:session][:email].downcase)
    if (lead_contact and user = lead_contact.contactable.user and user.authenticate(params[:session][:password]))
      sign_in user
      redirect_to_initial_page
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  private

  def redirect_to_initial_page
    if current_user.in_hax_organization?
      initial_page_path = session[:return_to] || teams_index_path
      redirect_to initial_page_path
    else
      redirect_to orders_path
    end
  end

end
