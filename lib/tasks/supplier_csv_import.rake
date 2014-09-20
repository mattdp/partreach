desc 'import suppliers from csv'
task :supplier_csv_import => :environment do
  # expected field layout: website,name,email,phone,street_address,city,state,zip
  CSV.new(open(ENV["url"]), headers: true).each do |row|

    # skip if supplier with this exact name already exists
    # TODO do a fuzzy match
    next if Supplier.find_by_name(row['name'])

    s = Supplier.new({
      name: row['name'],
      name_for_link: Supplier.proper_name_for_link(row['name']),
      url_main: row['website']
    })

    s.rfq_contact = RfqContact.create({ email: row['email'], phone: row['phone'] })
    s.contract_contact = ContractContact.create
    s.billing_contact = BillingContact.create

    address_params = {
      street: row['street_address'],
      zip: row['zip'],
      city: row['city'],
      state: row['state'],
      country: row['state'] ? 'US' : nil
    }
    s.create_or_update_address(address_params)

    p "Supplier #{s.name} Saved" if s.save
  end
end