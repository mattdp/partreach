# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

suppliers = Supplier.create([
	{ name: "ExampleToDelete1", url_main: "fakesupplier.com", url_materials: "fakesupplier.com/materials", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" },
	{ name: "ExampleToDelete2", url_main: "fakesupplier.com", url_materials: "fakesupplier.com/materials", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" }
	])