class SessionsController < ApplicationController
  skip_before_action :allow_staging_access, only: [:new, :create, :edit, :update]
  before_filter :correct_user, only: [:internal_edit, :internal_update]

  HOURS_ALLOWED = 48

  def new
    sign_out
    render layout: "provider"
  end

  def create
    lead_contact = LeadContact.find_by_email(params[:session][:email].downcase)
    if (lead_contact and user = lead_contact.contactable.user and user.authenticate(params[:session][:password]))
      sign_in user
      redirect_after_signin
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', layout: "provider"
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end

  def edit
    @user = User.find_by_password_reset_token(params[:id])
    if @user.nil?
      redirect_to new_password_reset_path, :alert => "Invalid password reset token."
    elsif @user.password_reset_sent_at < HOURS_ALLOWED.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired. For security, each reset is good for #{HOURS_ALLOWED} hours)."
    else
      render layout: "provider"
    end
  end

  def update
    @user = User.find_by_password_reset_token(params[:id])
    if @user.nil?
      redirect_to new_password_reset_path, :alert => "Invalid password reset token."
    elsif @user.password_reset_sent_at < HOURS_ALLOWED.hours.ago
      redirect_to new_password_reset_path, :alert => "Password reset has expired. For security, each reset is good for #{HOURS_ALLOWED} hours)."
    elsif @user.update_attributes(password_reset_params)
      sign_in @user
      redirect_after_signin("Password has been set. You are now logged in.")
    else
      render :edit, layout: "provider"
    end
  end

  def internal_edit
    @user = User.find_by_id(params[:id])
    render layout: "provider"
  end

  def internal_update
    @user = User.find_by_id(params[:id])

    if @user.update_attributes(password_reset_params)    
      sign_in @user
      redirect_after_signin("New password has been set. You are now logged in.")
    else
      render :internal_edit, layout: "provider"
    end
  end


  private

  def correct_user
    @user = User.find(params[:id])
    redirect_to teams_index_path unless (@user == current_user or current_user.admin?)
  end

  def password_reset_params
    params.require(:user).permit(:password,:password_confirmation)
  end

  def redirect_after_signin(notice=nil)
    if current_user.in_organization?
      initial_page_path = session[:return_to] || teams_index_path
      redirect_to initial_page_path, :notice => notice
    else
      redirect_to orders_path, :notice => notice
    end
  end

end
