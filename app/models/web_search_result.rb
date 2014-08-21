class WebSearchResult < ActiveRecord::Base

  belongs_to :web_search_item
  belongs_to :action_taken_by, class_name: User, foreign_key: "action_taken_by_id"
  belongs_to :supplier

  scope :in_priority_order, -> { includes(:web_search_item).order('web_search_items.priority desc, web_search_results.created_at desc') }
  scope :matches_exclusions, -> { where("domain IN (SELECT domain FROM search_exclusions)") }
  scope :matches_suppliers, -> { joins("JOIN suppliers s ON s.url_main LIKE '%' || domain || '%'") }
  scope :unexamined, -> { where(action: nil) }

  def self.quantity_for_examination(quantity)
    if quantity == 'all'
      return WebSearchResult.unexamined.in_priority_order.take(all)
    else
      return WebSearchResult.unexamined.in_priority_order.take(quantity)
    end
  end

  def record_action(choice, user, supplier=nil)
    update(action: choice, action_taken_by: user, supplier: supplier)
    WebSearchResult.mark_duplicates(domain, id)
  end

  def self.mark_duplicates(domain, except_id)
    WebSearchResult.where(domain: domain).where.not(id: except_id).update_all(action: 'duplicate_domain')
  end


  def self.search_google(item)
    WebSearchResult.search_loop(item)

    # delete results with domains matching existing suppliers
    WebSearchResult.unexamined.matches_suppliers.delete_all
    # delete results with domains that have been excluded as not being suppliers
    WebSearchResult.unexamined.matches_exclusions.delete_all

    item.update!(run_date: DateTime.now, net_new_results: item.web_search_results.count)
  end

  private

  def self.search_loop(item)
    position = 1
    results_count = 0
    opts = { start: 1 }
    loop do
      print '.' # show progress
      if item.num_requested && (item.num_requested - results_count < 10)
        opts[:num] = item.num_requested - results_count
      end
      page = GoogleCustomSearchApi.search(item.query, opts)
      
      # NOTE: Google CSE currently has limit of 100 results per query
      if page["error"]
        print "\n" # terminate progress indicator dots with newline
        return
      end

      page["items"].each do |search_result|
        url = Domainatrix.parse(search_result["link"])
        item.web_search_results.create!(
          :position => position,
          :domain => "#{url.domain}.#{url.public_suffix}",
          :link => search_result["link"],
          :title => search_result["title"],
          :snippet => search_result["snippet"]
          )
        position += 1
        results_count += 1
        if item.num_requested && (results_count >= item.num_requested)
          print "\n" # terminate progress indicator dots with newline
          return
        end
      end

      if page.queries["nextPage"]
        opts[:start] = page.queries.nextPage.first.startIndex
      else
        print "\n" # terminate progress indicator dots with newline
        return
      end
    end
  end

end
