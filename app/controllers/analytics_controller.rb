class AnalyticsController < ApplicationController
	before_filter :admin_user

	def home
	end

	def rfqs
		@orders = Order.rfqs_order
	end

	def suppliers
		signed = Supplier.all_signed
		claimed = Supplier.all_claimed
		@listings = {
			"Suppliers that are signed:" => signed,
			"Suppliers that have claimed profiles:" => claimed
		}		
	end

	def emails
	end

	def machines
		@machines = Machine.all.sort_by{ |m| [m.manufacturer,m.name] }
	end

	def metrics
		potential_date = Date.new(2013,3,2)
		dates = []
		while potential_date < Date.today
			dates << potential_date
			potential_date = potential_date + 7
		end
		@titles = ["Week", "Leads and Users", "RFQ Creates","Closed RFQs","Reviews","Profiles claimed", "Suppliers joined network"]
		printout = [] #titles
		dates.each do |date|
			unit = []
			unit << date
			unit << Lead.where("created_at > ? AND created_at < ?", date, date + 7).count + User.where("created_at > ? AND created_at < ?", date, date + 7).count
			unit << Order.where("created_at > ? AND created_at < ?", date, date + 7).count
			unit << Event.where("created_at > ? AND created_at < ? AND model = ? AND happening = ?", date, date + 7, "Order", "closed_successfully").count
			unit << Review.where("created_at > ? AND created_at < ?", date, date + 7).count
			unit << Event.where("created_at > ? AND created_at < ? AND model = ? AND happening = ?", date, date + 7, "Supplier", "claimed_profile").count
			unit << Event.where("created_at > ? AND created_at < ? AND model = ? AND happening = ?", date, date + 7, "Supplier", "joined_network").count
			printout << unit
		end
		@printout = printout
	end

end
