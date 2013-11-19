module DataAnalysis

	def asks_data
		answer = {}
		all_real_asks = Ask.where("real = true")
		Supplier.find_each do |s|
			supplier_asks = all_real_asks.where("supplier_id = ?",s.id)
			total = supplier_asks.count
			if total > 0
				answer[s.name] = [
					supplier_asks.where("request = 'description_requested'").count,
					supplier_asks.where("request = 'machines_requested'").count,
					supplier_asks.where("request = 'reviews_requested'").count
				]
			end
		end
		return answer
	end

	def paid_supplier_quotes
		op = "Order date\tOrder #\tSupplier_id\tSupplier_name\tTotal cost\n"
		Dialogue.find_each do |d|
			next if !d.supplier_id.present? or !d.order_id.present?
			s = Supplier.find(d.supplier_id)
			next if !s.is_in_network?
			o = Order.find(d.order_id)
			op += "#{o.created_at}\t#{o.id}\t#{s.id}\t#{s.name}\t#{d.total_cost}\n"
		end
		puts op
	end

end