class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :family
      t.text :note

      t.timestamps
    end
  end
end
