
source 'https://rubygems.org'
ruby "2.0.0"

gem 'rails', '4.0.0'
gem 'webrick', '= 1.3.1' #https://github.com/JumpstartLab/curriculum/issues/373
gem 'bootstrap-sass', '3.0.2.1'
gem 'faker', '1.2.0'
gem 'newrelic_rpm', '3.6.6.147'
gem 's3_direct_upload'
gem 'paperclip', '3.5.1' #https://github.com/thoughtbot/paperclip
gem 'pg', '0.17.1' #http://blog.willj.net/2011/05/31/setting-up-postgresql-for-ruby-on-rails-development-on-os-x/
gem 'twilio-ruby', '3.10.1'
gem 'dalli', '2.6.4' #https://devcenter.heroku.com/articles/building-a-rails-3-application-with-memcache
gem 'memcachier', '0.0.2' #https://devcenter.heroku.com/articles/building-a-rails-3-application-with-memcache
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'jquery-rails', '3.0.4'
gem 'bloggy', '0.2.2'
gem 'sitemap_generator', '4.2.0' #https://github.com/kjvarga/sitemap_generator
gem 'fog', '1.15.0' #for remote sitemap_generator uploads
gem 'bugsnag', '1.6.1' #https://devcenter.heroku.com/articles/bugsnag#using-with-rails-3-x-4
gem 'analytics-ruby', '<1.0' #https://segment.io/libraries/ruby
gem 'delayed_job_active_record', '4.0.0'
gem 'nokogiri', '1.6.0'
gem 'domainatrix', '0.0.11'
gem 'rb-readline', '0.5.1'
gem 'google_custom_search_api'

#old assets block
gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
 	gem 'rspec-rails', '2.14.0'
 	gem 'shoulda-matchers', '2.3.0'
 	gem 'pry', '0.9.12.2'
	gem 'pry-rails', '0.3.2'
	gem 'pry-nav', '0.2.3'
end

group :development do
	gem 'annotate', '2.5.0'
end

group :test do
	gem 'capybara', '2.1.0'
	gem 'launchy', '2.4.0'
	gem 'factory_girl_rails', '4.2.1'
	gem 'database_cleaner', '1.2.0'
end

group :production, :staging do
	gem 'rails_12factor', '0.0.2'
	gem 'heroku-api', '0.3.15'
end