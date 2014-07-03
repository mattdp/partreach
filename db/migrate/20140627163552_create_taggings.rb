class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :tag, null: false
      t.references :taggable, polymorphic: true, index: true, null: false
      t.string :source
      t.references :last_updated_by
      t.integer :confidence
      t.text :notes

      t.timestamps
    end
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type], unique: true

    reversible do |dir|
      # one-time data migration
      dir.up do
        # create taggings from existing combos
        sql = <<-SQL
          INSERT INTO taggings (tag_id, taggable_id, taggable_type, created_at, updated_at)
          SELECT tag_id, supplier_id, 'Supplier', now(), now() from combos;
        SQL
        TagGroup.connection.execute(sql)
      end
    end

  end
end


