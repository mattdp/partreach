module DataEntry

	def list_dialogues(order_id)
		answer = "Ord\tDia\tSupplier"
		Dialogue.all.each do |d|
			if d.order_id == 16
				answer += "#{order_id}\t#{d.id}\t#{Supplier.find(d.supplier_id).name}\n"
			end
		end
		return answer
	end

	

end