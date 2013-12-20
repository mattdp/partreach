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

	# def initialize
	# end

	# def self.get(name)
	# end

end