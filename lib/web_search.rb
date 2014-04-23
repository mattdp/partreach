class WebSearch

  def self.search_google(query, output_file=nil, opts = {})
    output_file ||= "#{query}.csv"
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
