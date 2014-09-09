class Crawler::Admin < CrawlerRefactor
  def initialize(args)
    super(args)
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
end