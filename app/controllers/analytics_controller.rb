class AnalyticsController < ApplicationController
	before_filter :admin_user

	def home
	end

	def rfqs
		@orders = Order.rfqs_order
	end

	def suppliers
		@signed = [Supplier.first]
		@claimed = [Supplier.last]
	end

	def emails
	end

end
