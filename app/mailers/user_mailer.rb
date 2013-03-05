class UserMailer < ActionMailer::Base
  default from: "noreply@supplybetter.com"

  def welcome_email(user)
  	@user = user
  	@url = Rails.env.production? ? "http://www.supplybetter.com" : "http://localhost:3000"
  	mail(to: @user.email, subject: "Welcome to #{brand_name}")
  end

  def bid_completed_email(user,order)
  	@user = user
  	@order = order
  	@url = orders_path(order)
  	mail(to: @user.email, subject: "Your #{brand_name} quotes have arrived")
  end
  
end
