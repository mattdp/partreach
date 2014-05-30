class CreateWebSearchTerms < ActiveRecord::Migration
  def change
    create_table :web_search_terms do |t|
      t.string :query
      t.integer :priority
      t.datetime :run_date
      t.integer :num_requested
      t.integer :net_new_results
      t.integer :suppliers_added

      t.timestamps
    end

    add_index :web_search_terms, :id

    remove_column :web_search_results, :query, :string
    add_reference :web_search_results, :web_search_term
  end
end
