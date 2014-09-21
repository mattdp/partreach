desc 'import suppliers from csv'
task :supplier_csv_import => :environment do
  # expected field layout: website,name,email,phone,street_address,city,state,zip
  CSV.new(open(ENV["url"]), headers: true).each do |row|

    # skip if supplier with this exact name already exists
    # TODO do a fuzzy match
    next if Supplier.find_by_name(row['name'])

    begin
      new_supplier = Supplier.new({
        name: row['name'],
        name_for_link: Supplier.proper_name_for_link(row['name']),
        url_main: row['website']
      })

      new_supplier.rfq_contact = RfqContact.create({ email: row['email'], phone: row['phone'] })
      new_supplier.contract_contact = ContractContact.create
      new_supplier.billing_contact = BillingContact.create

      address_params = {
        street: row['street_address'],
        zip: row['zip'],
        city: row['city'],
        state: row['state'],
        country: row['state'] ? 'US' : nil
      }
      new_supplier.create_or_update_address(address_params)

      new_supplier.source = 'csv_import'
      Tag.tag_set(:csv_import,:id).each do |id|
        new_supplier.add_tag(id)
      end

      new_supplier.save!
      puts "***** ADDED SUPPLIER: #{new_supplier.name}"

    rescue ActiveRecord::ActiveRecordError => e
      puts "ERROR attempting to add: #{new_supplier.name}"
      puts e.message
    end
  end

end