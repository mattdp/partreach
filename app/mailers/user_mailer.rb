class UserMailer < ActionMailer::Base
  default from: "noreply@partreach.com"

  def welcome_email(user)
  	@user = user
  	@url = Rails.env.production? ? "http://partreach.com" : "http://localhost:3000"
  	mail(to: @user.email, subject: "Welcome to PartReach")
  end

end
