class AddUniqueIndexOnGeographiesNameForLink < ActiveRecord::Migration
  def up
    change_column :geographies, :name_for_link, :string, null: false
    add_index :geographies, :name_for_link, :unique => true
  end
  def down
    change_column :geographies, :name_for_link, :string, null: true
    remove_index :geographies, :name_for_link
  end
end
