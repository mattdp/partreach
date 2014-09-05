class AddIndexesToTagRelationships < ActiveRecord::Migration
  def change
    # don't allow multiple instances of same relationship between same pair of tags
    add_index :tag_relationships, [:tag_relationship_type_id, :source_tag_id, :related_tag_id],
      :unique => true, name: 'index_tag_relationships_unique'
    # to support inverse lookups
    add_index :tag_relationships, :related_tag_id
  end
end
