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

  def scan_for_tags(tags)
    docs_text = self.load_documents.join('')
    tags.each do |t|
       @supplier.add_tag(t.id) if docs_text.match(/#{t.readable}/i)
    end
  end
end