desc 'import suppliers from csv'
task :import => :environment do
  file_location = ENV['file_location']
  # will need to save a local file as most likely the file will
  # be coming from AWS

  CSV.foreach(file_location, headers: true) do |row|

    s = Supplier.create({
      name: row['name'],
      name_for_link: row['name'].gsub(/\W/, ''),
      main_url: row['website']
    })
    rc = RfqContact.create({
      email: row['email'],
      phone: row['phone']
    })
    cc = ContractContact.create
    bc = BillingContact.create

    state = Geography.where("LOWER(short_name) = ? OR LOWER(long_name) = ?", row['state'].downcase, row['state'].downcase)
    state_id = state ? state.id : nil
    country_id = state ? 1 : nil

    a = Adress.create({
      state_id: state_id,
      country_id: country_id,
      address: row['street_address'],
      zip: row['zip'],
      city: row['city']
    })

    s.address = a
    s.billing_contact = bc
    s.rfq_contact = rc
    s.contract_contact = cc

    s.save
  end
end