class AnalyticsController < ApplicationController
	before_filter :admin_user

	def home
	end

	def rfqs
		@orders = Order.rfqs_order
	end

	def suppliers
		signed = Supplier.quantity_by_tag_id("all",Tag.find_by_name("n3_signedAndNDAd").id)
		signed = signed.concat(Supplier.quantity_by_tag_id("all",Tag.find_by_name("n5_signed_only").id))
		claimed = Supplier.where("claimed = true")
		@listings = {
			"Suppliers that are signed:" => signed,
			"Suppliers that have claimed profiles:" => claimed
		}		
	end

	def emails
	end

end
