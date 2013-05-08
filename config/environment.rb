# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Partreach::Application.initialize!

ActionMailer::Base.smtp_settings = {
  :user_name => "supplybetter",
  :password => ENV['SB_MAILER_PASSWORD'],
  :domain => "www.supplybetter.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :authentication => :plain,
  :enable_starttls_auto => true
}