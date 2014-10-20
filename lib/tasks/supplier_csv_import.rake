desc 'import suppliers from csv'
task :supplier_csv_import => :environment do
  # expected field layout: website,name,email,phone,street_address,city,state,zip,country
  CSV.new(open(ENV['url']), headers: true).each do |row|
    puts "***** IMPORT DATA: #{row.to_csv}"

    supplier_params = {}
    supplier_params[:name] = row['name'].strip if row['name']
    supplier_params[:url_main] = row['website'].strip if row['website']

    contact_params = {}
    contact_params[:email] = row['email'].strip if row['email']
    contact_params[:phone] = row['phone'].strip if row['phone']

    address_params = {}
    address_params[:street] = row['street_address'].strip if row['street_address']
    address_params[:city] = row['city'].strip if row['city']
    address_params[:state] = row['state'].strip if row['state']
    address_params[:zip] = row['zip'].strip if row['zip']
    address_params[:country] = row['country'].strip if row['country']

    url = Domainatrix.parse(row['website'])
    existing_supplier = (
      Supplier.where("url_main like ?", "%#{url.domain}.#{url.public_suffix}%").first ||
      Supplier.where("lower(name) = ?", row['name'].downcase).first ||
      Supplier.where("lower(name_for_link) = ?", Supplier.proper_name_for_link(row['name'])).first
    )

    begin
      if existing_supplier
        contact = existing_supplier.rfq_contact
        address = existing_supplier.address
        puts "***** FOUND EXISTING SUPPLIER: #{existing_supplier.url_main},#{existing_supplier.name},#{contact.email},#{contact.phone},#{address.street},#{address.city},#{address.state.short_name},#{address.zip},#{address.country.short_name}"
        if (ENV['update'] == 'true')
          existing_supplier.update!(supplier_params)
          existing_supplier.rfq_contact.update!(contact_params)
          existing_supplier.create_or_update_address(address_params)
          puts "***** UPDATED SUPPLIER: #{existing_supplier.name} (#{existing_supplier.id})"
        else
          # skip if supplier with this domain, name, or name_for_link already exists
          puts "***** SKIPPING DUPLICATE: #{existing_supplier.name} (#{existing_supplier.id})"
        end
      else
        new_supplier = Supplier.new(supplier_params)
        new_supplier.name_for_link = Supplier.proper_name_for_link(row['name'])

        new_supplier.rfq_contact = RfqContact.create(contact_params)
        new_supplier.contract_contact = ContractContact.create
        new_supplier.billing_contact = BillingContact.create

        new_supplier.create_or_update_address(address_params)

        new_supplier.source = 'csv_import'
        Tag.tag_set(:csv_import,:id).each do |id|
          new_supplier.add_tag(id)
        end

        new_supplier.save!
        puts "***** ADDED SUPPLIER: #{new_supplier.name} (#{new_supplier.id})"
      end
    rescue ActiveRecord::ActiveRecordError => e
      puts "***** ERROR attempting to add or update: #{e.message}"
    end
  end
end