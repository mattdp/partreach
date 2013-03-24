module DataEntry

	require 'csv'

	# CURRENT USE - csv_to_hashes(filepath) on local machine, result = <output> on heroku,
	# call hashes_to_saved_changes(result) on heroku

	def list_dialogues(order_id)
		answer = "Ord_id\tDia_id\tSupplier\n"
		Dialogue.all.each do |d|
			if d.order_id == order_id
				answer += "#{order_id}\t#{d.id}\t#{Supplier.find(d.supplier_id).name}\n"
			end
		end
		return answer
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