class TagRelationshipTypeNotNull < ActiveRecord::Migration
  def change
    change_column :tag_relationships, :tag_relationship_type_id, :integer, null: false
  end
end
