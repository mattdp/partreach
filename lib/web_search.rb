class WebSearch
	require 'csv'

	def self.search_google(query, output_file=nil, opts = {})
		output_file ||= "#{query}.csv"
 	  opts[:start] ||= 1

		CSV.open(output_file, "wb") do |csv|
		  csv << ["query", "position", "title", "url", "snippet"]
		  position = 0
	    begin
	      page = GoogleCustomSearchApi.search(query,opts)
	      break if page["error"]
				print "."
				page["items"].each do |item|
				  position += 1
				  csv << [query, position, item["title"], item["link"], item["snippet"]]
				end
	    end while opts[:start] = page.queries.nextPage.first.startIndex

		end
	end

end
