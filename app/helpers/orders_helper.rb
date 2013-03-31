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

	def winner(order)
		order.dialogues.each do |d|
			return d if d.won 
		end
		return nil
	end
	
end