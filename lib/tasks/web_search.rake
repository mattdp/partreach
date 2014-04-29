desc "perform search via Google CSE"
task :search_google => :environment do
	query = ENV["query"]
	opts = {}
	opts[:num] = ENV["num"] if ENV["num"]
	opts[:start] = ENV["start"] if ENV["start"]

	if (query)
		WebSearchResult.search_google(query, opts)
	else
		puts 'Usage: rake search_google query="search terms" [OPTIONS]'
		puts 'OPTIONS:'
		puts '  num=max number of results'
		puts '  start=starting position in results'
	end
end
