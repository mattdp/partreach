class Uploader

  def self.temp_demo_call
    structured = Uploader.organize_raw_synapse_data("/Users/matt/Downloads/searchresults.csv",100000,true)
    cleaned = Uploader.combine_structured_data(structured,7,true)
    Uploader.upload_cleaned(cleaned,organization_id,true)
  end

  def self.upload_cleaned(cleaned,organization_id,debug=true)
    #eliminate existing POs

    #find a match between the provider name and a provider on the site.
    #this probably requires user input

    #if matched, then either submit or put into text the PO and comment

    #if matched, save address phone email if blank
  end

  #input: {PO number => [deduped rows from the right user]}
  #output: [PO number => {po_and_comment: {options block}, provider: {provider block}}]
  def self.combine_structured_data(structured,organization_id,debug=true)
    organization = Organization.find(organization_id)
    valid_emails = organization.users.map{|u| u.lead.lead_contact.email}
    answer = {} 

    structured.each do |key,info|

      if !valid_emails.include?(info[0][:contact_email])
        puts "Skip: PO #{key} has a non-participating user." if debug
        next
      end

      #does not yet have combined price/quantity/description
      consolidated = info[0]

      #combine price, quantity, description
      consolidated[:po_and_comment][:price] = info.sum{|i| i[:po_and_comment][:price]}.round(2)
      consolidated[:po_and_comment][:quantity] = info.sum{|i| i[:po_and_comment][:quantity]}
      consolidated[:po_and_comment][:description] = info.map{|i| i[:po_and_comment][:description]}.join("; ")

      puts "OK: PO #{key} added" if debug
      answer[key] = consolidated
    end
    return answer
  end

	#input: synapse raw data, a row to start, an org_id
	#output: {PO number => [deduped rows from the right user]}
	def self.organize_raw_synapse_data(csv_data,skip_below_their_PO_ID=0,debug=false)
		data = open(csv_data).read
		organized = {}
		po_line_ids_used = []
		last_po_id = 0
		row_counter = 2 #there is a header row

		CSV.parse(data, { :headers => true, :col_sep => ",", :skip_blanks => true }) do |row|
			their_po_id = row["PO ID"].to_i
			line_id = row["PO Line ID"].to_i

			if their_po_id < skip_below_their_PO_ID
				puts "Skip: Row #{row_counter} is below PO ID threshold." if debug
				row_counter += 1
				next
			end

			standard_row = {
        first_row_identifier: row_counter,
        contact_email: row['Requester Email'],
        po_and_comment: {
          description: row['Description'],
          price: row['Amount'].to_f,
          quantity: row['Quantity'].to_i,
          issue_date: Date.strptime(row['PO Date'], "%m/%d/%Y"),  
          id_in_purchasing_system: their_po_id,              
          project_name: row['Project Name'],
        },
				provider: {
          name_in_purchasing_system: row['Vendor Name'],
          address: row['Vendor Address'],
          phone: row['Vendor Phone'],
          email: row['Vendor Email'],
        }
       }

			if organized[their_po_id].present?
				if po_line_ids_used.include?(line_id)
					puts "Skip: Row #{row_counter} is a duplicate." if debug
				else
					organized[their_po_id] << standard_row
					puts "OK: #{row_counter} added to existing PO." if debug
				end
			else
				organized[their_po_id] = [standard_row]
				puts "OK: #{row_counter} is a new PO." if debug
			end

			if last_po_id != their_po_id
				po_line_ids_used = []
				last_po_id = their_po_id
			end
			
			po_line_ids_used << line_id
			row_counter += 1

		end

		return organized
	end

	#this was the everything method before
	def self.create_synapse_pos_and_comments_from_tsv(organization_id, url)

		organization = Organization.find(organization_id)	  	
    
    output_string = ""    
    warning_prefix = "***** "

    tsv_data = open(url).read #http://ruby-doc.org/stdlib-2.0.0/libdoc/stringio/rdoc/StringIO.html

    CSV.parse(tsv_data, { :headers => true, :col_sep => "\t", :skip_blanks => true }) do |row|

      provider = nil  
      user = nil

      #test if row is supposed to be processed
      if !(row["Custom Part?"] == "TRUE" and row["Vendor already exists?"] == "TRUE")
        output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, not custom part or not vendor in DB\n"
        next
      end
      if row["Synapse PO number"].to_i == 0
        output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, no PO number present\n"
        next
      end
      if PurchaseOrder.where("id_in_purchasing_system = ?",row["Synapse PO number"].to_i).present?
        output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, PO #{row["Synapse PO number"]} already in system\n"
        next
      end

      #test if provider exists
      provider = Provider.safe_name_check(organization.id,row["Vendor Name"])
      if !provider.present?
        output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, provider not found in this organization\n"
        next
      end

      #test if user exists
      if !(row["SB U ID"].present? and
        user = User.where("id = ?",row["SB U ID"].to_i) and
        user.present? and
        organization.teams.include?(user[0].team))
          output_string += "#{warning_prefix}Row starting with SB ID #{row['Start SB ID']} skipped, user not found in this organization\n"
          next
      else
        user = user[0]
      end

      #create and test PO

      options = { description: row["Description"],
        project_name: row["Project Name"],
        id_in_purchasing_system: row["Synapse PO number"].to_i,
        price: row["Total Price"].to_f,
        quantity: row["Quantity"].to_i,
        issue_date: Date.parse(row["PO Issue Date"]),
        row_identifier: row['Start SB ID'],
        user: user}
      objects = provider.create_linked_po_and_comment!(options)
      output_string += objects[:output_string]
    end

    return output_string
  end

end