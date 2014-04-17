class CreateSearchExclusions < ActiveRecord::Migration
  def change
    create_table :search_exclusions do |t|
      t.string :domain

      t.timestamps
    end

    add_index :search_exclusions, [:domain]
  end
end
