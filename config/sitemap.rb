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
  add testimonials_path, changefreq: 'weekly'
 
  add '/blog'
  # how get each of the blog posts?

  ############################################
  # supplier directory landing pages, for SEO:
  ############################################

  # top-level directory landing page - list of countries
  add suppliers_path, changefreq: 'daily'

  # country and state landing pages
  country_names = ['unitedstates'] # for now, hard-code for unitedstates only
  country_names.each do |country_name|
    country = Geography.find_by_name_for_link(country_name)
    # country-level landing page - list of "states" within country
    add state_index_path(country.name_for_link)
  end

  # process tags within country-state (plus all states) landing pages
  Filter.find_each do |f|
    cst = f.name.match(/(\w+)-(\w+)-(\w+)/)
    ct = f.name.match(/(\w+)-(\w+)/)
    if cst.present?
      # country-state-process landing page
      add lookup_path(cst[1], cst[2], cst[3])
    elsif ct.present?
      # country-process landing page
      add lookup_path(ct[1], 'all', ct[2])
    end
  end

  # Supplier profiles
  sql = "SELECT country.name_for_link, state.name_for_link, suppliers.name_for_link \
        FROM suppliers \
        JOIN addresses ON addresses.place_id = suppliers.id AND addresses.place_type = 'Supplier' \
        JOIN geographies country ON addresses.country_id=country.id \
        JOIN geographies state ON addresses.state_id=state.id \
        WHERE country.name_for_link='unitedstates' AND suppliers.profile_visible = true"
  ActiveRecord::Base.connection.select_all(sql).rows.each do |row|
    add lookup_path(row[0], row[1], row[2])
  end

  Machine.find_each do |m|
    add machine_profile_path(m.name_for_link), changefreq: 'daily' if m.profile_visible
  end

  Manufacturer.find_each do |m|
    add manufacturer_profile_path(m.name_for_link), changefreq: 'daily' if m.profile_visible
  end  

end
