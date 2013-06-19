class AnalyticsController < ApplicationController
	before_filter :admin_user

	def home
	end

	def rfqs
		@orders = Order.rfqs_order
	end

	def suppliers
	end

	def emails
	end

end
