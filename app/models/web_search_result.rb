class WebSearchResult < ActiveRecord::Base

  def self.quantity_for_examination(quantity)
    if quantity == 'all'
      return WebSearchResult.all
    else
      return WebSearchResult.take(quantity)
    end
  end

  scope :matches_exclusions, -> { where("domain IN (SELECT domain FROM search_exclusions)") }
  scope :matches_suppliers, -> { joins("JOIN suppliers s ON s.url_main LIKE '%' || domain || '%'") }

  def self.delete_all_with_matching_domain(id)
	if (item = WebSearchResult.find(id))
		WebSearchResult.delete_all(["domain = ?", item.domain])
	end
  end

end
