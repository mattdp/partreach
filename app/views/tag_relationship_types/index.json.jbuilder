json.array! @relationship_types do |rt|
    json.merge! rt.attributes
end