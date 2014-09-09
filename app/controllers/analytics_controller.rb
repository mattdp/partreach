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
    @titles_and_orders = Order.invoicing_helper
  end

  def machines
    @machines = Machine.all.sort_by{ |m| [m.manufacturer.name.downcase,m.name.downcase] }
  end

  def metrics
    metrics = Order.metrics(:months,Date.new(2013,8,3))
    @titles = metrics[:titles] 
    @printout = metrics[:printout]
  end

end
