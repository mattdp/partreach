class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show
		@country = params[:country].upcase
		@state = params[:state].upcase
		@tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
		@suppliers = Supplier.quantity_by_tag_id("all",@tag.id,@country,@state)
		@valid_guide = true
	end

end