#having everything be class methods feels odd right now
#but it may make sense when running them concurrently

#find/replace the output of the verbose stuff to reroute it
#   didn't know how to variabalize after 20m work

class Crawler
	require 'open-uri'

	MAX_PAGES_PER_SITE = 10

	private 

		def self.sleeper
			sleep 5 + rand(3)
		end

		def self.openable?(url,explored)
			if explored.include?(url)
				$stdout.puts "#{url} has already been examined. Skipping." 
				return false
			else
				return true
			end
		end

		#returns page or false. updates the explored array
		def self.url_tryer(url,explored)
			if Crawler.openable?(url,explored)
				explored << url #either way, it's tested		
				begin
					page = Nokogiri::HTML(open(url))
					$stdout.puts "Opened #{url}"
				rescue
					$stdout.puts "Open failed for #{url}"
				end
				sleeper
				return page #nil if failed
			else
				return nil
			end
		end

		#returns parsed_url or false
		def self.page_opener(raw_url,master_parsed_url,explored)
			begin
				parsed_url = Domainatrix.parse(raw_url)
			rescue StandardError => e
				$stdout.puts "#{raw_url} is not a valid domain name. Skipping."
				return false
			end
			if !(parsed_url.domain == master_parsed_url.domain or parsed_url.domain == "" or !(parsed_url.host.include?("www") or parsed_url.host.include?("http")) )
				$stdout.puts "#{raw_url} isn't on the master domain, #{master_parsed_url.domain}. Skipping."
				return false
			end
			if (parsed_url.path != "" and parsed_url.path[0] == "#")
				$stdout.puts "#{raw_url} is an anchor link. Skipping."
				return false 
			end

			#parsed_url is now tested

			$stdout.puts "Attempting raw url..."
			page = Crawler.url_tryer(raw_url,explored)

			if page.nil?
				$stdout.puts "Reattempt: adding host prefix to relative link..."
				page = Crawler.url_tryer("http://#{master_parsed_url.host}#{parsed_url.path}",explored)
			end

			if page.nil?
				$stdout.puts "Reattempt: appending host to master domain..."
				page = Crawler.url_tryer("http://#{master_parsed_url.host}/#{parsed_url.host}",explored)
			end

			return page #either exists or nil

		end

		#return false if not crawled, path if crawled
		def self.page_crawl(input_url, master_parsed_url, links_to_explore, explored, site_info)
			
			page = Crawler.page_opener(input_url,master_parsed_url,explored)
			return false unless page

			text = page.text

			site_info[:zip] << text.scan(/(\d{5})/)
			#looking near zip codes only
			site_info[:state] << text.scan(/([A-Z]{2})[\s,]+\d{5}/)
			site_info[:email] << text.scan(/([\w+\-.]+@[a-z\d\-.]+\.[a-z]{1,5})\s/i)
			#phone-groups of 3 3 4 separated by at most 2 of any char, without numbers on either end
			site_info[:phone] << text.scan(/(\d{3,4}).{,2}(\d{3}).{,2}(\d{4})/)

			new_links = page.css('a').map{|l| l['href']}
			links_to_explore.concat(new_links)

			return true
		end

		def self.site_crawl(starting_point)
			pages_crawled = 0
			explored = [] #list of paths where been already
			links_to_explore = [starting_point]
			site_info = { #candidates for that piece of information
				phone: [],
				email: [],
				zip: [],
				state: []
			}

			begin
				master_parsed_url = Domainatrix.parse(starting_point)
			rescue StandardError => e
				$stdout.puts "#{starting_point} is not a valid domain name. Skipping."
				return false 	
			end
			$stdout.puts "Master domain for #{starting_point} is '#{master_parsed_url.domain}'"

			while pages_crawled < MAX_PAGES_PER_SITE and !links_to_explore.empty?
				link = links_to_explore.shift
				pages_crawled += 1 if Crawler.page_crawl(link, master_parsed_url, links_to_explore, explored, site_info)
			end

			return site_info
		end

		def self.crawl_launcher
			inputs = [
				["MMI","http://www.mmisonora.com"]
			]

			answer = {}

			inputs.each do |input|
				$stdout.puts "---\nExamining site: '#{input[0]}'\n---"
				answer[input[0]] = Crawler.site_crawl(input[1])
			end

			return answer
		end

		def self.crawl_processer
			raw_data = Crawler.crawl_launcher
			processed_data = {}

			$stdout.puts "Processing results."
			if !raw_data.empty?
				raw_data.each do |company,information| #ie {"shapeways": {BLOB}}
					processed_data[company] = {}
					information.each do |attribute,values| #ie {phone: [[["230","424","9334"],["432","545","2341"]]]}
						if !values.flatten.empty?
							#get a workable list from the convoluted .scan structure
							if attribute != :phone
								values = values.flatten
							elsif attribute == :phone
								values = values.flatten(1) #so happy this exists
								values = values.map{|a,b,c| "#{a}#{b}#{c}"}
							end
							#get a frequency distribution
							#http://stackoverflow.com/questions/9480852/array-to-hash-words-count
							frequency = Hash.new(0)
							values.map{ |value| frequency[value] += 1 }
							#take the top ones
							processed_data[company][attribute] = frequency.max_by{|k,v| v}[0]
						else
							processed_data[company][attribute] = nil
						end
					end

				end
			end

			return processed_data

		end

end