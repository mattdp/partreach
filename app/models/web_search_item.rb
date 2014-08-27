class WebSearchItem < ActiveRecord::Base
  DEFAULT_PRIORITY = 5
  has_many :web_search_results

  def self.add_item(query, priority, num_requested)
    create!(query: query, priority: priority, num_requested: num_requested)
  end

  def self.queued
    where(run_date: nil).order(priority: :desc, created_at: :desc)
  end

  def self.batch(batch_size)
    queued.limit(batch_size)
  end

  def self.increment_suppliers_added_count(id)
    WebSearchItem.increment_counter(:suppliers_added, id)
  end

end
