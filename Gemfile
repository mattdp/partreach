
source 'https://rubygems.org'
ruby "2.0.0"

gem 'rails', '~> 4.1.0'
gem 'webrick', '= 1.3.1' #https://github.com/JumpstartLab/curriculum/issues/373
gem 'bootstrap-sass', '3.0.2.1'
gem 'faker'
gem 'newrelic_rpm'
gem 's3_direct_upload'
gem 'pg', '0.17.1' #http://blog.willj.net/2011/05/31/setting-up-postgresql-for-ruby-on-rails-development-on-os-x/
gem 'twilio-ruby', '3.10.1'
gem 'bcrypt'
gem 'jquery-rails', '3.0.4'
gem 'bloggy', '0.2.2'
gem 'sitemap_generator', '4.2.0' #https://github.com/kjvarga/sitemap_generator
gem 'fog', '1.15.0' #for remote sitemap_generator uploads
gem 'bugsnag', '1.6.1' #https://devcenter.heroku.com/articles/bugsnag#using-with-rails-3-x-4
gem 'delayed_job_active_record'
gem 'nokogiri', '1.6.0'
gem 'domainatrix', '0.0.11'
gem 'rb-readline', '0.5.1'
gem 'google_custom_search_api', '1.0.0'
gem 'angularjs-rails'
gem 'angular-ui-bootstrap-rails'
gem 'gon'
gem 'jbuilder'
gem 'd3-rails'
gem 'rails_admin'
gem 'chosen-rails'
# nested_form: latest released version is 0.3.2, from Apr 5, 2013
# but we need fix from pull request #266  https://github.com/ryanb/nested_form/pull/266,
# merged Jun 18, 2013  https://github.com/ryanb/nested_form/commit/42028bc06e72a848d297edc1467a969a7c9def57
# plus possibly additional fix made Nov 8, 2013 https://github.com/ryanb/nested_form/commit/35a2cf060680280413880337a3f89bdec469301c
# subsequent commits as of Nov 14, 2014 revision: 1b0689dfb4d230ceabd278eba159fcb02f23c68a are documentation updates only
gem 'nested_form', github: 'ryanb/nested_form'
gem 'mechanize'
gem 'StreetAddress', :require => "street_address"
gem 'aws-sdk', '~> 2'
gem 'intercom-rails'
#https://devcenter.heroku.com/articles/rack-cache-memcached-rails31
gem 'rack-cache'
gem 'dalli'
gem 'kgio'
#end caching

#old assets block
gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'bourbon'
gem 'neat'

group :development, :test do
  gem 'rspec-rails', '2.14.0'
  gem 'shoulda-matchers'
  gem 'pry', '0.9.12.2'
  gem 'pry-rails', '0.3.2'
  gem 'pry-nav', '0.2.3'
  gem 'dotenv-rails'
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
