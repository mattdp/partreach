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
    elsif dl.supplier_working
      "Waiting for supplier"
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
      elsif currency == "pounds"
        currency_symbol = "£"
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

  def html_snippet_helper(url, order_id)
    suffix = url.split(".").last.upcase
    if suffix.in? ["PNG", "JPG"]
      <<-HTML
<p><a href="#{url}" alt="SupplyBetter RFQ#{order_id}>" target="_blank">
<img src="#{url}" alt="SupplyBetter RFQ#{order_id}" width="460">
</a></p>
      HTML
    else
      <<-HTML
<a href="#{url}">Link to #{suffix}</a>
      HTML
    end
  end
  
end