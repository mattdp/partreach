json.success true
json.communication do
  json.merge! @communication.attributes
  json.created_at @communication.created_at.strftime('%Y-%m-%d')
end