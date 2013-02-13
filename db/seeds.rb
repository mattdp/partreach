# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

suppliers = Supplier.create([
	{ name: "Shapeways", url_main: "http://www.shapeways.com", url_materials: "http://www.shapeways.com/materials", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" },
	{ name: "Ponoko", url_main: "https://www.ponoko.com/", url_materials: "http://www.ponoko.com/make-and-sell/materials/ponoko-united-states?kind=3D+Printed&mode=materials", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" }
	{ name: "Sculpteo", url_main: "http://www.sculpteo.com/", url_materials: "http://www.sculpteo.com/en/materials/", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" }
	{ name: "i.materialise", url_main: "http://i.materialise.com/", url_materials: "http://i.materialise.com/materials", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" }
	{ name: "RedEye", url_main: "http://www.redeyeondemand.com/", url_materials: "http://www.redeyeondemand.com/Materials.aspx", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" }
	{ name: "ZoomRP", url_main: "http://www.zoomrp.com/", url_materials: "http://www.zoomrp.com/products.aspx", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" }
	{ name: "PartSnap", url_main: "http://www.partsnap.com/", url_materials: "http://www.partsnap.com/3d-printing/3d-printing-materials-stratasys-fdm/", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" }
	{ name: "3Dproparts", url_main: "http://www.3dproparts.com/", url_materials: "http://3dproparts.com/technologies/3d-printing", blurb: "This is a fake supplier", email: "matt@fakesupplier.biz", phone: "4156401234" }

	])