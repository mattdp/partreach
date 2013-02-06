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
end