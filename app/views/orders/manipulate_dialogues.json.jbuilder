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
json.order_groups do
  json.array! @order.order_groups do |og|
    json.merge! og.attributes
  end
end