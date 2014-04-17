class WebSearchResults < ActiveRecord::Base

  def self.quantity_for_examination(quantity)
    if quantity == 'all'
      return WebSearchResults.all
    else
      return WebSearchResults.take(quantity)
    end
  end

end
