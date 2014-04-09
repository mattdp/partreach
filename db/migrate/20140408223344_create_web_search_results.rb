class CreateWebSearchResults < ActiveRecord::Migration
  def change
    create_table :web_search_results do |t|
      t.string :query
      t.string :position
      t.string :domain
      t.string :link
      t.string :title
      t.string :snippet

      t.timestamps
    end

    add_index :web_search_results, [:domain]
  end
end
