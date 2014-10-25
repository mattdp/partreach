class AnalyticsController < ApplicationController
  before_filter :admin_user

  def home
  end

  def rfqs
    @orders = Order.rfqs_order
  end

  def suppliers
    to_bother = Supplier.next_contact_suppliers_sorted
    signed = Supplier.all_signed
    claimed = Supplier.all_claimed
    @listings = {
      "Suppliers to bother:" => to_bother,
      "Suppliers that are signed:" => signed,
      "Suppliers that have claimed profiles:" => claimed
    }   
  end

  def emails
  end

  def phone
  end

  def invoicing
    @billable_bids_by_month = []

    dates = Order.date_ranges(:months,Date.today-360)
    index = 0
    #-2 since using dates[index] and dates[index+1]
    while (index <= dates.length - 2)
      closed_orders = Order.closed_orders(dates[index], dates[index+1])
      billable_bids = Dialogue.billable_by_supplier(closed_orders)
      @billable_bids_by_month << { month: dates[index], billable_bids: billable_bids }

      index += 1
    end

    @billable_bids_by_month.reverse
  end

  def machines
    @machines = Machine.all.sort_by{ |m| [m.manufacturer.name.downcase,m.name.downcase] }
  end

  def metrics
    metrics = Order.metrics(:months,Date.new(2013,8,3))
    @titles = metrics[:titles] 
    @printout = metrics[:printout]
  end

  def web_search_results
    query = <<-SQL
    SELECT wsr.id, web_search_items.query, wsr.domain, wsr.action, suppliers.name_for_link, contacts.name, wsr.updated_at
    FROM web_search_results wsr
    JOIN web_search_items ON web_search_items.id=wsr.web_search_item_id
    JOIN leads ON leads.user_id=wsr.action_taken_by_id
    JOIN contacts ON contactable_id=leads.id AND contactable_type='Lead'
    LEFT OUTER JOIN suppliers ON suppliers.id=wsr.supplier_id
    WHERE action IS NOT NULL AND action_taken_by_id IS NOT NULL
    AND wsr.updated_at >= ? AND wsr.updated_at < ?
    ORDER BY wsr.id desc;
    SQL

    @rows = WebSearchResult.find_by_sql [query, params['starting'], params['before']]
  end

end
