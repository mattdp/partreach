class PasswordResetsController < ApplicationController
  def new
  end

  def create
  	user = User.find_by_email(params[:email])
  	user.send_password_reset if user
  	redirect_to root_url, :notice => "Email sent with password reset instructions."
  end

  def edit
  	@user = User.find_by_password_reset_token!(params[:id])
  end

  def update
  	@user = User.find_by_password_reset_token!(params[:id])
    hours_allowed = 48
  	if @user.password_reset_sent_at < hours_allowed.hours.ago
  		redirect_to new_password_reset_path, :alert => "Password reset has expired (Each reset is good for #{hours_allowed} hours). Try again."
  	elsif @user.update_attributes(password_reset_params)
      sign_in @user
  		redirect_to orders_path, :notice => "Password has been set. You are now logged in."
  	else
  		render :edit
  	end
  end

  private

    def password_reset_params
      params.permit(:user)
    end

end
