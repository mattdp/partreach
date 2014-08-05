class BidSet

  attr_accessor :bids

  def initialize
    @bids = []
  end
    
  def include(bid)
    @bids << bid
  end

  def count
    @bids.size
  end

  def total_cost
    return nil unless common_currency
    total = 0.0
    @bids.each do |bid|
      total += bid.total_cost
    end
    total
  end

  def average_cost
    return nil unless common_currency
    total_cost / count
  end

  def common_currency
    return nil if count == 0
    @bids.each do |bid|
      return nil if bid.currency != @bids[0].currency
    end
    return @bids[0].currency
  end

  def bids_sorted_by_price!
    if common_currency
      @bids.sort! do |x,y|
        x.total_cost <=> y.total_cost
      end
    end
    @bids
  end


end
