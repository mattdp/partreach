class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show
		@country = params[:country].upcase
		@state = params[:state].upcase
		@tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
		supplier_holder = Supplier.visible_profiles_sorted(nil,@tag,@country,@state)
		@supplier_information_arrays = supplier_holder[@country][@state]
		@valid_guide = true
	end

end