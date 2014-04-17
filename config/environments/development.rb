Partreach::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  Paperclip.options[:command_path] = "/usr/local/bin"

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.

  #this should be the steady state for development
  config.action_mailer.delivery_method = :test

  # use this for testing. never commit with this uncommented
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   :authentication => :plain,
  #   :address => "smtp.mailgun.org",
  #   :port => 587,
  #   :domain => "supplybetter.com",
  #   :user_name => "postmaster@supplybetter.com",
  #   :password => ENV['SB_MAILER_PASSWORD']
  # }

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => "localhost:3000" }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = true
end
