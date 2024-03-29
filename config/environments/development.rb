Partreach::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

#### TOGGLE IF YOU WANT MAILTRAP ACTIVE IN DEVELOPMENT

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :user_name => '23757f9b722070397',
    :password => '59decc2a1c50ba',
    :address => 'mailtrap.io',
    :domain => 'mailtrap.io',
    :port => '2525',
    :authentication => :cram_md5,
    :enable_starttls_auto => true
  }

  config.action_mailer.perform_deliveries = true 

#### TOGGLE IF YOU WANT TO AVOID MAILTRAP IN DEVELOPMENT

  # config.action_mailer.delivery_method = :test

#### BELOW ALWAYS APPLIES

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => "localhost:3000" }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = true
end
