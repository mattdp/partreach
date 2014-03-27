module OrdersHelper

	def bids_received(order)

		dialogues = order.dialogues
		return 0 if dialogues == []
		return order.dialogues.map{|d| d.bid?}.count(true)

	end

	def bid_status(dl)

		if dl.recommended
			"Recommended"
		elsif dl.declined?
			"Declined to bid"
		elsif dl.bid?
			"Completed"
		elsif dl.supplier_working
			"Waiting for supplier"
		else
			"Pending"
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