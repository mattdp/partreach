require 'web_search.rb'

desc "perform search via Google CSE"
task :search_google => :environment do
	query = ENV["query"]
	file = ENV["file"]
	opts = {}
	opts[:num] = ENV["num"] if ENV["num"]
	opts[:start] = ENV["start"] if ENV["start"]

	if (query)
		WebSearch.search_google(query, file, opts)
	else
		puts 'Usage: rake search_google query="search terms" [OPTIONS]'
		puts 'OPTIONS:'
		puts '  file=path/to/output_file.csv'
		puts '  num=max number of results'
		puts '  start=starting position in results'
	end
end
