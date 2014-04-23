class WebSearchResult < ActiveRecord::Base

  def self.quantity_for_examination(quantity)
    if quantity == 'all'
      return WebSearchResult.all
    else
      return WebSearchResult.take(quantity)
    end
  end

end
