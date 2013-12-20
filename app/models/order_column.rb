#sets of information that could possibly be displayed on an order

class OrderColumn
	def self.all
    
    list = {
      supplier_name: {
        header: "Bid status",
        code: "bid_status(d)",
        css_class: "center"
      },
      total_cost: { 
        header: "Total cost",
        code: "currencyize(d.total_cost, d.currency)",
        css_class: "right"
      },
      process_time: {
        header: "Time (days)",
        code: "d.process_time",
        css_class: "center"
      },
      material: {
        header: "Material",
        code: "d.material",
        css_class: "center"
      },
      process: {
        header: "Process",
        code: "d.process_name",
        css_class: "center"
      },
      process_cost: {
        header: "Process cost" ,
        code: "currencyize(d.process_cost, d.currency)",
        css_class: "right"
      },
      shipping_cost: {
        header: "Shipping cost",
        code: "currencyize(d.shipping_cost, d.currency)",
        css_class: "right"
      },
      notes: {
        header: "Notes",
        code: "notarize(d.shipping_name,d.notes)",
        css_class: "center"
      }                 
    }

    return list
	end

  def self.get_columns(set=:all)
    map = OrderColumn.set_to_names_map
    column_set = map[set]
    return OrderColumn.all.select{|k,v| column_set.include?(k)}
  end

  #broken out so that admin views can offer these as options
  def self.set_to_names_map
    hash = {}
    hash[:all] = OrderColumn.all.keys
    hash[:few] = [:shipping_cost,:notes]
    return hash
  end

end