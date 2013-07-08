module DataAnalysis

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

	end

end