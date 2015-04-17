class PasswordResetsController < ApplicationController
  skip_before_action :allow_staging_access, only: [:new, :create, :edit, :update]
  
  HOURS_ALLOWED = 48

  def new
    render layout: "provider"
  end

  def create
    lead_contact = LeadContact.find_by_email(params[:email])
    if lead_contact 
      user = lead_contact.contactable.user
      user.send_password_reset if user
    end
    redirect_to root_url, :notice => "Email sent with password reset instructions."
  end

  def edit
    @user = User.find_by_password_reset_token(params[:id])
    @hours_allowed = HOURS_ALLOWED

    render layout: "provider"
  end

  def update
    @user = User.find_by_password_reset_token!(params[:id])
    if @user.password_reset_sent_at < HOURS_ALLOWED.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired. For security, each reset is good for #{HOURS_ALLOWED} hours). Contact support@supplybetter.com to get another reset link."
    elsif @user.update_attributes(password_reset_params)
      sign_in @user
      redirect_to orders_path, :notice => "Password has been set. You are now logged in."
    else
      render :edit
    end

    render layout: "provider"
  end

  private

    def password_reset_params
      params.require(:user).permit(:password,:password_confirmation)
    end

end
