class GuidesController < ApplicationController

	def show
		@country = params[:country].upcase
		@state = params[:state].upcase
		@tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
		@suppliers = Supplier.quantity_by_tag_id("all",@tag.id,@country,@state)
	end

end