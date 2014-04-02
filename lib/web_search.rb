class WebSearch
	require 'csv'

	def self.search_google(query, output_file=nil)
		output_file ||= "#{query}.csv"

		CSV.open(output_file, "wb") do |csv|
		  csv << ["query", "position", "title", "url"]

			results = GoogleCustomSearchApi.search(query)

			results["items"].each_with_index do |item, index|
			  csv << [query, index+1, item["title"], item["link"]]
			end
		end

	end

end
