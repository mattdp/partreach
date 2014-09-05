json.tag do 
  json.merge! @tag.attributes
end
json.process_tags @process_tags.each do |tag|
  json.id         tag.id
  json.readable   tag.readable
end