class AddColumnsToWebSearchResult < ActiveRecord::Migration
  def change
    add_column :web_search_results, :action, :string
    add_reference :web_search_results, :action_taken_by
    add_reference :web_search_results, :supplier
  end
end
