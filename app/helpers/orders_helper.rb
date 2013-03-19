module OrdersHelper

	def bids_received(order)

		received = 0
		order.dialogues.each do |d|
			if d.response_received and d.total_cost > 0 
				received += 1
			end
		end

		return received

	end

	def bid_status(dl)

		if dl.response_received
			if dl.total_cost > 0
				"Completed"
			elsif dl.total_cost== 0
				"Declined to bid"
			else
				"Error: contact support"
			end
		else
			"Pending"
		end

	end

	def dollarize(amount)

		if amount.nil?
			return "-"
		else
			return "$#{amount}"
		end

	end

	def notarize(shipping,notes)
		if !shipping.nil? and !notes.nil?
			"#{shipping}; #{notes}"
		else
			"#{shipping}#{notes}"
		end
	end

	def winner(order)
		order.dialogues.each do |d|
			return d if d.won 
		end
		return nil
	end
	
end