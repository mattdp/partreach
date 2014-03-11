# first, run
# >require 'DataEntry'; include DataEntry; csv_to_tags("https://s3.amazonaws.com/temp_for_uploading/tags_v12.csv")

desc "Provide basic sample data so site has some examples"
task populate: :environment do
	User.create_with_dummy_password("Matt","mdpfwds@gmail.com",true)
	User.create_with_dummy_password("Rob","rob@supplybetter.com",true)
	User.create_with_dummy_password("Nonadmin","nobody@fake.spam.biz")

	tag_3dp = Tag.find_by_name("3d_printing")
	manufacturer = Manufacturer.create_or_reference_manufacturer({name: "Platysys"})
	m1 = Machine.create_or_reference_machine({name: "Printerizer", manufacturer_id: manufacturer.id})
	m2 = Machine.create_or_reference_machine({name: "Extrudinator", manufacturer_id: manufacturer.id})

	supplier = Supplier.new({
		name: "Fakeways",
		name_for_link: "fakeways",
		url_main: "fakeways.com",
		description: "like shapeways, but less so."
	})
	supplier.create_or_update_address({
		country: "US",
		state: "PA",
		zip: "19087"
		})
	Contact.create_or_update_contacts(supplier,{})
	supplier.save
	supplier.add_tag(tag_3dp.id)
	supplier.add_tag(10)
	supplier.add_tag(15)
	supplier.add_machine(m1.id,3)
	s1 = supplier

	supplier = Supplier.new({
		name: "BlueEye",
		name_for_link: "blueeye",
		url_main: "blueeye.com",
		description: "like redeye, but less so."
	})
	supplier.create_or_update_address({
		country: "US",
		state: "NC"
		})
	Contact.create_or_update_contacts(supplier,{})
	supplier.save
	supplier.add_tag(tag_3dp.id)
	supplier.add_tag(8)
	supplier.add_tag(16)
	supplier.add_tag(24)
	supplier.add_machine(m1.id,2)		
	supplier.add_machine(m2.id,4)	
	s2 = supplier

	supplier = Supplier.new({
		name: "PhotoMold",
		name_for_link: "photomold",
		url_main: "photomold.com",
		description: "like protomold, but less so."
	})
	supplier.create_or_update_address({
		country: "US",
		state: "NC",
		zip: "27601"
		})
	Contact.create_or_update_contacts(supplier,{})
	supplier.save	
	supplier.add_tag(8)
	s3 = supplier

end