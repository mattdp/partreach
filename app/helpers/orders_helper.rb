module OrdersHelper

	def bids_received(order)

		received = 0
		order.dialogues.each do |d|
			if d.response_received and d.bid > 0 
				received += 1
			end
		end

		return received

	end

	def bid_status(dl)

		if dl.response_received
			if dl.bid > 0
				"Completed"
			elsif dl.bid == 0
				"Declined to bid"
			else
				"Error: contact support"
			end
		else
			"Pending"
		end

	end

	def bid_amount(dl)

		op = dl.bid
		op = "-" if op.nil?
		return op

	end

end