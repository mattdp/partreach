# Load the rails application
require File.expand_path('../application', __FILE__)

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Partreach::Application.initialize!

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
	:authentication => :plain,
	:address => "smtp.mailgun.org",
  :port => 587,
  :domain => "supplybetter.com",
  :user_name => "postmaster@supplybetter.com",
  :password => ENV['SB_MAILER_PASSWORD']
}