class WebSearch

  def self.search_google(query, opts = {})
    WebSearch.search_loop(query, opts)

    # delete results with domains matching existing suppliers
    WebSearchResult.matches_suppliers.delete_all
    # delete results with domains that have been flagged as not suppliers
    WebSearchResult.matches_exclusions.delete_all
  end

  private   

  def self.search_loop(query, opts)
    position = (opts[:start] ? opts[:start].to_i : 1)
    num = opts[:num].to_i
    results_count = 0

    loop do
      page = GoogleCustomSearchApi.search(query,opts)
      
      if page["error"] # end when Google returns error due to max results exceeded
        print "\n" # terminate progress indicator dots with newline
        return
      end

      print '.' # show progress

      page["items"].each do |item|
        url = Domainatrix.parse(item["link"])
        domain = "#{url.domain}.#{url.public_suffix}"
        WebSearchResult.create!(
          :query => query,
          :position => position,
          :domain => domain,
          :link => item["link"],
          :title => item["title"],
          :snippet => item["snippet"]
          )
        position += 1
        results_count += 1
        return if opts[:num] && (results_count >= num)
      end

      opts[:start] = page.queries.nextPage.first.startIndex
    end
  end

end
