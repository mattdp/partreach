desc "add item to list of supplier searches to be run using Google CSE"
# Usage: rake add_web_search_item query="<search terms>" [priority=<priority>] [num_requested=<number_of_results_requested>]
task :add_web_search_item => :environment do
  query = ENV["query"]
  priority = ENV["priority"] ? ENV["priority"].to_i : WebSearchItem::DEFAULT_PRIORITY
    num_requested = ENV["num_requested"].to_i if ENV["num_requested"]

  if (query)
    WebSearchItem.add_item(query, priority, num_requested)
  else
    puts 'Usage: rake add_web_search_item query="<search terms>" [priority=<priority>] [num_requested=<number_of_results_requested>]'
  end
end

desc "run a set of supplier searches using Google CSE"
# Usage: rake run_supplier_search_batch [batch_size=<number_of_items_to_process>]
task :run_supplier_search_batch => :environment do
  size = ENV["batch_size"] || 10
  WebSearchItem.batch(size).each do |item|
    puts "running search for: #{item.query}"
    WebSearchResult.search_google(item)
    num_requested = item.num_requested ||= "max"
    puts "requested #{num_requested} results; yielded #{item.net_new_results} with new domains"
  end
end
