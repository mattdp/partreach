module ApplicationHelper

  def url_with_protocol(url) #from http://stackoverflow.com/questions/5012188/rails-link-to-external-site-url-is-attribute-of-user-table-like-users-websit
    /^http/.match(url) ? url : "http://#{url}"
  end

  def meta_description(desc = nil) #from http://nycdevshop.com/blog/creating-titles-and-seo-meta-tags-in-rails
    if desc.present?
      content_for :meta_description, desc
    else
      content_for?(:meta_description) ? content_for(:meta_description) : "SupplyBetter is effective Supplier Relationship Management (SRM) for hardware companies and OEMs."
    end
  end

  def us_3dprinting_path
    lookup_path("unitedstates", "all", "3dprinting")
  end

end
