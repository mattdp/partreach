json.merge! @order.attributes
json.order_created to_pacific_timezone(@order.created_at).strftime("%m/%d/%Y %H:%M (%Z)")
json.user do
  json.merge! @order.user.attributes
  json.address @order.user.address
  json.lead do 
    json.merge! @order.user.lead.attributes
    json.communications @order.user.lead.communications
    json.lead_contact do 
      json.merge! @order.user.lead.lead_contact.attributes
      json.full_name_untrusted @order.user.lead.lead_contact.full_name_untrusted
    end
  end
end
json.order_groups @order.order_groups do |og|
  json.merge! og.attributes
  json.alphabetical_dialogues og.alphabetical_dialogues do |ad|
    json.merge! ad.attributes
    json.supplier do
      json.merge! ad.supplier.attributes
      json.isInNetwork ad.supplier.is_in_network?
      json.rfq_contact ad.supplier.rfq_contact
    end
  end
  json.parts og.parts do |part|
    json.merge! part.attributes
    json.external part.external
  end
end