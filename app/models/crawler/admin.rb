class Crawler::Admin < CrawlerRefactor
  def initialize(args)
    super(args)
    @supplier = Supplier.find_by_url_main(args[:url])
  end

  def load_documents
    self.run if @html_documents.empty?
  end

  def html
    load_documents
    html = @html_documents.map{|page| page.inner_html}
  end

  def links
    load_documents
    links = @html_documents.map{|page| page.css('a').map{|l| l['href']} }
  end

  def scan_for_tags(tags, options = {})
    options = sft_defaults.merge(options)
    docs_text = self.load_documents.join('')
    tags.each do |t|
      if options[:test_mode] == false
        @supplier.add_tag(t.id) if docs_text.scan(/#{t.readable}/i).size > options[:n]
      else
        Rails.logger.info "#{@supplier.name} would get tag #{t.name}" if docs_text.scan(/#{t.readable}/i).size > options[:n]
      end
    end
  end

  def sft_defaults
    {test_mode: false, n: 1}
  end
end