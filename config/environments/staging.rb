Partreach::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # http://edgar.tumblr.com/post/30209472511/ruby-on-rails-how-to-add-http-basic-authentication
  # prevent access to staging for bots / passersby
  config.middleware.insert_after(::Rack::Runtime, "::Rack::Auth::Basic", "Partreach") do |u, p|
    [u, p] == [ENV['STAGING_HTTP_USER'], ENV['STAGING_HTTP_PASSWORD']]
  end

  # Code is not reloaded between requests
  config.cache_classes = true

  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.js_compressor = :uglifier

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # WHY was this set up for staging?  curious.
  # configure outbound email for Mailgun
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = {
  #   :authentication => :plain,
  #   :address => "smtp.mailgun.org",
  #   :port => 587,
  #   :domain => "supplybetter.com",
  #   :user_name => "postmaster@supplybetter.com",
  #   :password => ENV['SB_MAILER_PASSWORD']
  # }

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
  
  # Disable delivery errors, bad email addresses will be ignored
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = false
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.default_url_options = { :host => "http://quiet-waters-6381.herokuapp.com"}

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5
end
