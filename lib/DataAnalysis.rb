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

	def percent_quotes_won_by_paid_suppliers
		supplier_ids = Supplier.all_signed.map{|s| s.id}
		won = 0
		all = 0
		recommended = 0
		Dialogue.find_each do |d|
			if supplier_ids.include?(d.supplier_id)
				all += 1
				won += 1 if d.won
				recommended +=1 if d.recommended
			end
		end
		puts "#{won} won, #{all} total, #{won*1.0/all}% win rate, #{recommended*1.0/all} recommended rate" if all > 0 
	end

end