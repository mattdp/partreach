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

  def to_pacific_timezone(datetime)
    datetime.in_time_zone("Pacific Time (US & Canada)")
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
<a href="#{url}"><strong>Link to #{suffix}</strong></a>
      HTML
    end
  end

  def color_coding_css_class(past_experience)
    case past_experience
    when "Unknown"
      css_class = "experience-unknown"
    when "Qualified"
      css_class = "experience-qualified"
    when "Promising"
      css_class = "experience-promising"
    when "Mixed"
      css_class = "experience-mixed"
    else
      css_class = "experience-not-specified"
    end
    css_class
  end

end