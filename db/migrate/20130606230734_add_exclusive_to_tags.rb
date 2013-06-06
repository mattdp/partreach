class AddExclusiveToTags < ActiveRecord::Migration
  def change
    add_column :tags, :exclusive, :boolean, :default => false
  end
end
