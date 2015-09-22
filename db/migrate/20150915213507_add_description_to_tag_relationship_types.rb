class AddDescriptionToTagRelationshipTypes < ActiveRecord::Migration
  def change
    add_column :tag_relationship_types, :description, :string
  end
end
