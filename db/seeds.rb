# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

suppliers = Supplier.create([
	{ name: "Shapeways", 
		url_main: "http://www.shapeways.com", 
		url_materials: "http://www.shapeways.com/materials", 
		blurb: "Shapeways is a 3D Printing marketplace and community", 
		email: "service@shapeways.com", 
		phone: "N/A" },
	{ name: "Ponoko", 
		url_main: "https://www.ponoko.com/", 
		url_materials: "http://www.ponoko.com/make-and-sell/materials/ponoko-united-states?kind=3D+Printed&mode=materials", 
		blurb: "The world's easiest making system", 
		email: "service@ponoko.com", 
		phone: "N/A" }
	{ name: "Sculpteo", 
		url_main: "http://www.sculpteo.com/", 
		url_materials: "http://www.sculpteo.com/en/materials/", 
		blurb: "Innovative 3D printing service for creative people", 
		email: "contact@sculpteo.com", 
		phone: "18008141270" }
	{ name: "i.materialise", 
		url_main: "http://i.materialise.com/", 
		url_materials: "http://i.materialise.com/materials", 
		blurb: " i.materialise offers all people with an eye for design and a head full of ideas the possibility to turn these ideas into 3D reality", 
		email: "contact@i.materialise.com", 
		phone: "N/A" }
	{ name: "RedEye", 
		url_main: "http://www.redeyeondemand.com/", 
		url_materials: "http://www.redeyeondemand.com/Materials.aspx", 
		blurb: "Choose from a wide variety of high-performance engineering materials for your detailed functional prototypes, durable manufacturing tools and low-volume manufacturing needs.", 
		email: "GoDigital@redeyeondemand.com", 
		phone: "18668826934" }
	{ name: "ZoomRP", 
		url_main: "http://www.zoomrp.com/", 
		url_materials: "http://www.zoomrp.com/products.aspx", 
		blurb: "We offer the fastest self-service prototype parts available", 
		email: "sales@zoomrp.com", 
		phone: "N/A" }
	{ name: "PartSnap", 
		url_main: "http://www.partsnap.com/", 
		url_materials: "http://www.partsnap.com/3d-printing/3d-printing-materials-stratasys-fdm/", 
		blurb: "PartSnap is a home-based business focused on  customer service and speed.", 
		email: "sales@partsnap.com", 
		phone: "12144491455" }
	{ name: "3Dproparts", 
		url_main: "http://www.3dproparts.com/", 
		url_materials: "http://3dproparts.com/technologies/3d-printing", 
		blurb: "Single source for all your design to manufacturing needs", 
		email: "info@3dproparts.com", 
		phone: "18773377672" }

	])