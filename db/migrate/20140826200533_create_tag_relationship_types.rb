class CreateTagRelationshipTypes < ActiveRecord::Migration
  def change
    create_table :tag_relationship_types do |t|
      t.string :name
      t.references :source_group, index: true
      t.references :related_group, index: true

      t.timestamps
    end

    # convert tag_relationships to indicate relationship via FK instead of string
    # CAUTION! doesn't migrate any existing data
    remove_column :tag_relationships, :relationship, :string
    add_reference :tag_relationships, :tag_relationship_type
  end
end
