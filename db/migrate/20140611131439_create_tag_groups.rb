class CreateTagGroups < ActiveRecord::Migration
  def change
    create_table :tag_groups do |t|
      t.string    :group_name, :null => false
      t.boolean   :exclusive, :default => false

      t.timestamps
    end
    add_index :tag_groups, :group_name, unique: true

    add_reference :tags, :tag_group, index: true

    create_table :taggables do |t|
      t.string      :type_name, :null => false
      t.references  :tag_group, :null => false
      t.timestamps
    end
    add_index :taggables, [:type_name, :tag_group_id], unique: true


    puts <<-EOS
*
*
********************************************************************************************
*
* AFTER PERFORMING MIGRATION, BE SURE TO RUN db/scripts/migrate_tag_family_to_tag_groups.sql
*
********************************************************************************************
*
*
    EOS

  end
end
