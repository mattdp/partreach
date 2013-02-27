class UserMailer < ActionMailer::Base
  default from: "noreply@partreach.com"

  def welcome_email(user)
  	@user = user
  	@url = Rails.env.production? ? "http://partreach.com" : "http://localhost:3000"
  	mail(to: @user.email, subject: "Welcome to PartReach")
  end

  def bid_completed_email(user,order)
  	@user = user
  	@order = order
  	@url = orders_path(order)
  	mail(to: @user.email, subject: "Your PartReach quotes have arrived")
  end
  
end
