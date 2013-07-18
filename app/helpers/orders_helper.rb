#!/bin/env ruby
# encoding: utf-8

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

	def winner(order)
		order.dialogues.each do |d|
			return d if d.won 
		end
		return nil
	end
	
end