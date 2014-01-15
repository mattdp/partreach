class AnalyticsController < ApplicationController
	before_filter :admin_user

	def home
	end

	def rfqs
		@orders = Order.rfqs_order
	end

	def suppliers
		to_bother = Supplier.next_contact_suppliers_sorted
		signed = Supplier.all_signed
		claimed = Supplier.all_claimed
		@listings = {
			"Suppliers to bother:" => to_bother,
			"Suppliers that are signed:" => signed,
			"Suppliers that have claimed profiles:" => claimed
		}		
	end

	def emails
	end

	def phone
	end

	def machines
		@machines = Machine.all.sort_by{ |m| [m.manufacturer.name.downcase,m.name.downcase] }
	end

	def metrics
		interval = :months
		tracking_start_date = Date.new(2013,3,2)
		dates = []

		if interval == :months
			#list of months, including one to two beyond the current one
			dates = ((tracking_start_date)..(Date.today+31)).map{|d| Date.new(d.year, d.month, 1) }.uniq
		elsif interval == :weeks
			while tracking_start_date < (Date.today + 7)
				dates << tracking_start_date
				tracking_start_date += 7
			end
		end

		@titles = [interval.to_s, "Leads and Users", "RFQ Creates","Closed RFQs","Reviews","Profiles claimed", "Suppliers joined network", "Quote value of orders"]
		printout = [] #titles
		index = 0
		#-2 since using dates[index] and dates[index+1]
		while index <= dates.length - 2		
			unit = []
			unit << dates[index]
			unit << Lead.where("created_at > ? AND created_at < ?", dates[index], dates[index+1]).count + User.where("created_at > ? AND created_at < ?", dates[index], dates[index+1]).count
			unit << Order.where("created_at > ? AND created_at < ?", dates[index], dates[index+1]).count
			unit << Event.where("created_at > ? AND created_at < ? AND model = ? AND happening = ?", dates[index], dates[index+1], "Order", "closed_successfully").count
			unit << Review.where("created_at > ? AND created_at < ?", dates[index], dates[index+1]).count
			unit << Event.where("created_at > ? AND created_at < ? AND model = ? AND happening = ?", dates[index], dates[index+1], "Supplier", "claimed_profile").count
			unit << Event.where("created_at > ? AND created_at < ? AND model = ? AND happening = ?", dates[index], dates[index+1], "Supplier", "joined_network").count
			unit << Order.where("created_at > ? AND created_at < ?", dates[index], dates[index+1]).sum{|o| o.quote_value}.to_s
			printout << unit
			index += 1
		end
		@printout = printout
	end

end
