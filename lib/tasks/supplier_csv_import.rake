desc 'import suppliers from csv'
task :import => :environment do
  file_location = ENV['file_location']
  # will need to save a local file as most likely the file will
  # be coming from AWS

  CSV.foreach(file_location, headers: true) do |row|
    next if Supplier.find_by_name(row['name'])

    s = Supplier.new({
      name: row['name'],
      name_for_link: row['name'].gsub(/\W/, ''),
      url_main: row['website']
    })
    rc = RfqContact.create({
      email: row['email'],
      phone: row['phone']
    })
    cc = ContractContact.create
    bc = BillingContact.create

    lower_state = row['state'] ? row['state'].downcase : 'NOT RECORDED'
    state = Geography.where("LOWER(short_name) = ? OR LOWER(long_name) = ?", lower_state, lower_state).first
    state_id = state ? state.id : nil
    country_id = state ? 1 : nil

    a = Address.create({
      state_id: state_id,
      country_id: country_id,
      street: row['street_address'],
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