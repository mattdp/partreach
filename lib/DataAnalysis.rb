module DataAnalysis

	def paid_supplier_quotes
		op = "Order date\tOrder #\tSupplier_id\tSupplier_name\tTotal cost\n"
		Dialogue.find_each do |d|
			s = Supplier.find(d.supplier_id)
			next if !s.is_in_network?
			o = Order.find(d.order_id)
			op += "#{o.created_at}\t#{o.id}\t#{s.id}\t#{s.name}\t#{d.total_cost}\n"
		end
		puts op
	end

	#return array of emails
	def emails_of_paying_suppliers
		t1 = Tag.find_by_name("n3_signedAndNDAd")
		t2 = Tag.find_by_name("n5_signed_only")
		tags = [t1,t2]

		emails = []
		no_email_found = []

		tags.each do |t|
			combos = Combo.where("tag_id = ?",t.id)
			combos.each do |c|
				s = Supplier.find(c.supplier_id)
				if s.email.nil? or s.email == ""
					no_email_found << s.name
				else 
					emails << s.email
				end 
			end
		end

		no_email_found.each do |name|
			puts "No email found for #{name}!"
		end

		return emails
	end

	#return array of emails
	#DOES NOT have unsubscriptions or false emails taken into account, nor does the system have them
	def emails_of_buyers_and_leads
		emails = []
		getter = Proc.new {|x| emails << x.email unless x.email.nil? or x.email == ""}
		User.all.map &getter
		Lead.all.map &getter
		return emails.uniq
	end

end