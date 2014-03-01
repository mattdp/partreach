# https://github.com/kjvarga/sitemap_generator/wiki/Generate-Sitemaps-on-read-only-filesystems-like-Heroku
# controlled by a rake task, rake sitemap:refresh, run each 24h on heroku

# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://www.supplybetter.com"
# pick a place safe to write the files
SitemapGenerator::Sitemap.public_path = 'tmp/'
# store on S3 using Fog
SitemapGenerator::Sitemap.adapter = SitemapGenerator::S3Adapter.new
# inform the map cross-linking where to find the other maps
SitemapGenerator::Sitemap.sitemaps_host = "http://#{ENV['FOG_DIRECTORY']}.s3.amazonaws.com/"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:

  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add new_review_path, changefreq: 'weekly'
  add new_order_path, changefreq: 'weekly'
  add order_questions_path, changefreq: 'weekly'
  add signin_path, changefreq: 'weekly'
  add getting_started_path, changefreq: 'weekly'
  add be_a_supplier_path, changefreq: 'weekly'
  add materials_path, changefreq: 'weekly'
  add terms_path, changefreq: 'weekly'
  add privacy_path, changefreq: 'weekly'
  add suppliers_path, changefreq: 'daily'
  add testimonials_path, changefreq: 'weekly'
 
  add '/blog'
  # how get each of the blog posts?

  Supplier.find_each do |s|
    add supplier_profile_path(s.name_for_link), changefreq: 'daily' if s.profile_visible
  end

  Filter.find_each do |f|
    add "/guides/#{f.name.gsub(/[-]/,'/')}", changefreq: 'daily'
  end

  Machine.find_each do |m|
    add machine_profile_path(m.name_for_link), changefreq: 'daily' if m.profile_visible
  end

  Manufacturer.find_each do |m|
    add manufacturer_profile_path(m.name_for_link), changefreq: 'daily' if m.profile_visible
  end  

end
