#sets of information that could possibly be displayed on an order

class OrderColumn
  def self.all
    
    list = {
      past_experience: {
        header: "Confidence rating",
        code: "d.past_experience",
        css_class: "center"
      },
      bid_status: {
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
    hash[:speed] =   [:bid_status,:total_cost,:process_time,:notes]
    hash[:cost] =    [:bid_status,:total_cost,:process_time,:notes]
    hash[:quality] = [:bid_status,:total_cost,:process,:process_time,:notes]
    return hash
  end

end