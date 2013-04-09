#!/bin/env ruby
# encoding: utf-8

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

		if dl.recommended
			"Recommended"
		elsif dl.response_received
			if dl.total_cost.nil? or dl.total_cost == 0
				"Declined to bid"
			elsif dl.total_cost > 0
				"Completed"
			else
				"Error: contact support"
			end
		else
			"Pending"
		end

	end

	def currencyize(amount, currency)

		if amount.nil?
			return "-"
		else
			if currency == "dollars"
				currency_symbol = "$"
			elsif currency == "euros"
				currency_symbol = "€"
			else
				currency_symbol = ""
			end
			return sprintf("#{currency_symbol}%.02f",amount)
		end
	end

	def notarize(shipping,notes)
		if !shipping.nil? and !notes.nil?
			"#{shipping}; #{notes}"
		else
			"#{shipping}#{notes}"
		end
	end

	def sorted_dialogues(all_dialogues)
		# should be: 
    # recommended, in nonzero low to high
    # completed, in nonzero low to high
    # declined, alphabetical
    # pending, alphabetical
    sorted_dialogues = []

    recommended = []
    completed = []
    declined = []
    pending = []

    all_dialogues.each do |d|
      if d.recommended
        recommended << d 
      elsif d.response_received and (!d.total_cost.nil? and d.total_cost > 0)
        completed << d
      elsif d.response_received
        declined << d
      else
        pending << d
      end
    end

    [recommended, completed, declined, pending].each do |piece|
      @sorted_dialogues.concat piece.sort_by! { |m| Supplier.find(m.supplier_id).name.downcase }
    end
  end

	def winner(order)
		order.dialogues.each do |d|
			return d if d.won 
		end
		return nil
	end
	
end