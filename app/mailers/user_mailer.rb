class UserMailer < ActionMailer::Base
  default from: "noreply@supplybetter.com"
  include SessionsHelper

  def welcome_email(user)
  	@user = user
    @brand_name = brand_name
  	@url = Rails.env.production? ? "http://www.supplybetter.com" : "http://localhost:3000"
  	mail(to: @user.email, subject: "Welcome to #{brand_name}")
  end

  def bid_completed_email(user,order)
  	@user = user
  	@order = order
  	@url = orders_path(order)
  	mail(to: @user.email, subject: "Your #{brand_name} quotes have arrived")
  end

  def password_reset(user)
    @user = user
    @brand_name = brand_name
    mail(to: @user.email, subject: "Password reset requested")
  end
  
end
