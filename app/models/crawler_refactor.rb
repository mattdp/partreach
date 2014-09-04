class CrawlerRefactor
  require 'open-uri'

  def initialize(args)
    args = defaults.merge(args)
    @max_pages = args[:max_pages]
    @urls = [args[:url]]
    @starting_url_object = Domainatrix.parse(args[:url])
    @completed_urls = []
    @html_documents = []
    @pages_crawled = 0
  end

  def run
    raise ArgumentError, 'Needs a url' if @urls.empty?
    while @pages_crawled <= @max_pages && @urls.any?
      url = @urls.shift
      @current_url_object = Domainatrix.parse(url)
      page = self.open_page

      @urls = @urls | page.css('a').map{|l| l['href']} if page

      @completed_urls << url
      @html_documents << page if page
      @pages_crawled += 1
    end
    @html_documents
  end

  protected
    def open_page
      return nil if page_should_be_skipped?

      page = build_html_and_sleep
    end

    def build_html_and_sleep
      page = self.run_nokogiri(@current_url_object.url) ||
             self.run_nokogiri("#{@starting_url_object.scheme}://#{@starting_url_object.host}#{@current_url_object.path}")
      sleep(5 + rand(3))
      page
    end

    def run_nokogiri(url)
      begin
        page = Nokogiri::HTML(open(url))
        Rails.logger.info "Opened #{url}"
      rescue
        Rails.logger.debug "Open failed for #{url}"
      end
      page
    end
  
    def page_should_be_skipped?
      if !(@current_url_object.domain == @starting_url_object.domain || @current_url_object.domain == "" or !(@current_url_object.host.include?("www") or @current_url_object.host.include?("http")) )
        Rails.logger.info "current url isn't on the master domain, #{@starting_url_object.domain}. Skipping."
        true
      elsif (@current_url_object.path != "" and @current_url_object.path[0] == "#")
        Rails.logger.info "current url is an anchor link. Skipping."
        true
      else
        false
      end
    end

    def defaults
      {max_pages: 15}
    end
end