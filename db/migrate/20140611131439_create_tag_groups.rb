class CreateTagGroups < ActiveRecord::Migration
  def change
    create_table :tag_groups do |t|
      t.string    :group_name, :null => false
      t.boolean   :exclusive, :default => false

      t.timestamps
    end
    add_index :tag_groups, :group_name, unique: true

    add_reference :tags, :tag_group, index: true

    create_table :taggable_types do |t|
      t.string      :type_name, :null => false
      t.references  :tag_group, :null => false
      t.timestamps
    end
    add_index :taggable_types, [:type_name, :tag_group_id], unique: true


    reversible do |dir|
      # one-time data migration
      dir.up do
        # create tag_groups from existing tags
        sql = <<-SQL
          INSERT INTO tag_groups (group_name, exclusive, created_at, updated_at)
          SELECT DISTINCT family, exclusive, now(), now() FROM tags;
        SQL
        TagGroup.connection.execute(sql)

        # set FK in tags
        sql = <<-SQL
          UPDATE tags
          SET tag_group_id = tag_groups.id, updated_at = now()
          FROM tag_groups WHERE group_name = family;
        SQL
        TagGroup.connection.execute(sql)

        # make all of these tag groups applicable to Suppliers
        sql = <<-SQL
          INSERT INTO taggable_types (type_name, tag_group_id, created_at, updated_at)
          SELECT 'Supplier', id, now(), now() FROM tag_groups;
        SQL
        TaggableType.connection.execute(sql)
      end
    end
  end
end
