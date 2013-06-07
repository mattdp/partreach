class AddReadableToTags < ActiveRecord::Migration
  def change
    add_column :tags, :readable, :string
  end
end
