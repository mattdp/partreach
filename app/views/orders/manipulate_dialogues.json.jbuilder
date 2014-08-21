json.merge! @order.attributes
json.user do
  json.merge! @order.user.attributes
  json.lead do 
    json.merge! @order.user.lead.attributes
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
    json.supplier ad.supplier
  end
  json.parts og.parts do |part|
    json.merge! part.attributes
    json.external part.external
  end
end