class CreateTagRelationships < ActiveRecord::Migration
  def change
    create_table :tag_relationships do |t|
      t.references :source_tag, null: false, index: true
      t.references :related_tag, null: false
      t.string :relationship, null: false

      t.timestamps
    end
    add_index :tag_relationships, [:related_tag_id, :source_tag_id, :relationship], unique: true, name: 'index_tag_relationships_unique'
  end
end
