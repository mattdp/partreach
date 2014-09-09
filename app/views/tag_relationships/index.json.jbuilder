json.tag_relationships @tag_relationships do |tr|
  json.name             tr
  json.paramaterized    tr.parameterize.underscore
end
json.graphs do
  @tag_relationships.each do |tr|
    json.set!     tr do
      json.id             @tag.id
      json.name           @tag.name
      json.children  @tag.tag_relationships.joins(:relationship).where('tag_relationship_types.name = ?', tr) do |sub_tr|
        json.id           sub_tr.related_tag.id
        json.name         sub_tr.related_tag.name
      end
      json.parents   @tag.reverse_tag_relationships.joins(:relationship).where('tag_relationship_types.name = ?', tr) do |sub_tr|
        json.id           sub_tr.source_tag.id
        json.name         sub_tr.source_tag.name
      end
    end
  end
end