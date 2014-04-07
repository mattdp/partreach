#!/bin/env ruby
# encoding: utf-8

module FormatHelper

  def currencyize(amount, currency)
    if amount.nil?
      return "-"
    else
      if currency == "dollars"
        currency_symbol = "$"
      elsif currency == "euros"
        currency_symbol = "€"
      elsif currency == "pounds"
        currency_symbol = "£"
      else
        currency_symbol = ""
      end
      return sprintf("#{currency_symbol}%.02f",amount)
    end
  end

end
