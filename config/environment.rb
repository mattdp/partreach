# Load the rails application
require File.expand_path('../application', __FILE__)

#http://stackoverflow.com/questions/4188677/ruby-on-rails-3-incompatible-character-encodings-utf-8-and-ascii-8bit-with-i18
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Partreach::Application.initialize!
