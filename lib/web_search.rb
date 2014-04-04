class WebSearch
  require 'csv'

  def self.search_google(query, output_file=nil, opts = {})
    output_file ||= "#{query}.csv"
    position = (opts[:start] ? opts[:start].to_i : 1)
    num = opts[:num].to_i
    results_count = 0

    CSV.open(output_file, "wb") do |csv|
      csv << ["query", "position", "title", "url", "snippet"]

      loop do
        page = GoogleCustomSearchApi.search(query,opts)
        return if page["error"]

        print "." # show progress
        page["items"].each do |item|
          csv << [query, position, item["title"], item["link"], item["snippet"]]
          position += 1
          results_count += 1
          return if opts[:num] && (results_count >= num)
        end

        opts[:start] = page.queries.nextPage.first.startIndex
      end
    end
  end

end
