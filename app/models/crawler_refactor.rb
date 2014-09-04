class CrawlerRefactor
  require 'open-uri'

  def initialize(args)
    args = defaults.merge(args)
    @max_pages = args[:max_pages]
    @urls = [args[:url]]
    @starting_url_object = run_domainatrix(args[:url])
    @completed_urls = []
    @html_documents = []
    @pages_crawled = 0
  end

  def run
    raise ArgumentError, 'Needs a url' if @urls.empty?
    while @pages_crawled <= @max_pages && @urls.any?
      url = @urls.shift
      @current_url_object = run_domainatrix(url)
      page = @current_url_object ? self.open_page : false

      @urls = @urls | page.css('a').map{|l| l['href'].gsub(/.*(?=http:\/\/)/, '')} if page

      @completed_urls << url
      @html_documents << page if page
      @pages_crawled += 1
    end
    @html_documents
  end

  protected
    def open_page
      return nil if self.page_should_be_skipped?

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

    def run_domainatrix(url)
      begin
        d_object = Domainatrix.parse(url)
      rescue StandardError => e
        d_object = nil
      end
      d_object
    end
  
    def page_should_be_skipped?
      if @starting_url_object.domain != @current_url_object.domain && (@current_url_object.domain == "" && @current_url_object.host != "")
        Rails.logger.info "#{@current_url_object.url} isn't on the master domain, #{@starting_url_object.domain}. Skipping."
        return true
      elsif (@current_url_object.path != "" && @current_url_object.path[0] == "#")
        Rails.logger.info "#{@current_url_object.url} is an anchor link. Skipping."
        return true
      else
        return false
      end
    end

    def defaults
      {max_pages: 15}
    end
end