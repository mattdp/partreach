module DataEntry

	require 'csv'

	# CURRENT USE - csv_to_hashes(filepath) on local machine, result = <output> on heroku,
	# call hashes_to_saved_changes(result) on heroku

	def usage_counter
		answer = "Num_Ord\tNum_Bid\tUsr_id\tUsr_email\n"
		total_order_counter = total_bid_counter = 0
		User.all.each do |u|
			order_counter = 0
			bid_counter = 0 # not all users have orders
			u.orders.each do |o|
				order_counter += 1
				bid_counter = 0
				o.dialogues.each do |d|
					bid_counter += 1 if (d.response_received and !d.total_cost.nil? and d.total_cost > 0)
				end
			end
			answer += "#{order_counter}\t#{bid_counter}\t"
			answer += "#{u.id}\t#{u.email}\n"
			total_bid_counter += bid_counter
			total_order_counter += order_counter
		end
		answer += "------\n#{total_order_counter}\t#{total_bid_counter}\t#{User.all.count}\tTotals\n"
		return answer
	end

	def list_dialogues(order_id)
		answer = "Ord_id\tDia_id\tSupplier\n"
		Dialogue.all.each do |d|
			if d.order_id == order_id
				answer += "#{order_id}\t#{d.id}\t#{Supplier.find(d.supplier_id).name}\n"
			end
		end
		return answer
	end

	#highly inflexible, based on "printabase-crawled-data"
	USE_ROW = 0
	COMPANY = 1
	IS_SERVICE_BUREAU = 2
	CLEANED_LINK = 3
	ADDRESS = 4
	COUNTRY_CODE = 5	

	def csv_to_suppliers(url)
		
		CSV.new(open(url)).each do |row|
			if row[USE_ROW] == "TRUE" and Supplier.find_by_name(row[COMPANY].downcase).nil?
				
				s = Supplier.new
				s.name = row[COMPANY]
				s.url_main = row[CLEANED_LINK]
				if s.save
					puts "#{s.name} saved successfully."
				else
					puts "Error saving #{s.name}"
				end
				
				if !row[ADDRESS].nil? and row[ADDRESS].length > 0
					a = Address.new
					a.country = row[COUNTRY_CODE]
					a.notes = row[ADDRESS]
					a.place_id = s.id
					a.place_type = "Supplier"
					if a.save
						puts "#{s.name}'s address saved successfully."
					else
						puts "Error saving #{s.name}'s address"
					end
				end
				
			end
		end

	end

	TAG_NAME = 0
	TAG_FAMILY = 1
	TAG_NOTE = 2

	def csv_to_tags(url)
		CSV.new(open(url)).each do |row|
			n = row[TAG_NAME]
			if !n.nil? and n.length > 0
				t = Tag.new
				t.name = n
				t.family = row[TAG_FAMILY]
				t.note = row[TAG_NOTE]
				if t.save
					puts "#{t.name} saved as new tag."
				else
					puts "Error saving #{t.name} as new tag."
				end
			end
		end
	end

	def csv_to_hashes(absolute_filepath)
		headers = []
		row_size = 0
		answer = []
		CSV.foreach(absolute_filepath) do |row|
			if row_size == 0
				row_size = row.size
				headers = row.map {|x| x.to_sym}
				return -1 unless headers[0] == :id
			elsif row.size == row_size
				row_hash = Hash.new
				(0..row.size-1).each do |n|
					row_hash[headers[n]] = row[n]
				end
				answer << row_hash
			else
				return -1 #need to have the rows all having a header, or odd stuff will happen
			end
		end
		return answer
	end

	def hashes_to_saved_changes(hashes)
		hashes.each do |h|
			#use ID to find dialogue
			d = Dialogue.find(h[:id])
			#remove ID from hash
			h.delete(:id)

			#if it's an all-string hash, set the data types correctly
			h.keys.each do |k|

				k = "" if k.nil?

				if [:process_cost, :shipping_cost, :total_cost].include? k
					h[k] = BigDecimal.new(h[k])
				elsif [:id].include? k
					h[k] = h[k].to_i
				end
			end

			#update attributes (check in testing if mass assignment works)
			d.update_attributes(h)
		end
	end

end