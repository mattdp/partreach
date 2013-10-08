class AddNflToTags < ActiveRecord::Migration
  def change
    add_column :tags, :name_for_link, :string
  end
end
