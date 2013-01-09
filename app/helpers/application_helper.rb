module ApplicationHelper

	def url_with_protocol(url) #from http://stackoverflow.com/questions/5012188/rails-link-to-external-site-url-is-attribute-of-user-table-like-users-websit
    /^http/.match(url) ? url : "http://#{url}"
  end

end
