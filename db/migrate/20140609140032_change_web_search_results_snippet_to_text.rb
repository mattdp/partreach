class ChangeWebSearchResultsSnippetToText < ActiveRecord::Migration
  def self.up
    change_column :web_search_results, :link, :text
    change_column :web_search_results, :snippet, :text
  end
 
  def self.down
    change_column :web_search_results, :link, :string
    change_column :web_search_results, :snippet, :string
  end
end  
