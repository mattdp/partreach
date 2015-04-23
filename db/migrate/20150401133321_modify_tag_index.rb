class ModifyTagIndex < ActiveRecord::Migration
  def up
    remove_index :tags, :name
    add_index :tags, [:name, :organization_id], :unique => true
  end
  def down
    remove_index :tags, [:name, :organization_id]
    add_index :tags, :name, :unique => true
  end
end
