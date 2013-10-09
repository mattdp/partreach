class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show
		@country = Word.transform(:name_for_link,params[:country],:shortform)
		@state = Word.transform(:name_for_link,params[:state],:shortform)
		@tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
		supplier_holder = Supplier.visible_profiles_sorted(nil,@tag,@country,@state)
		@supplier_information_arrays = []
		@supplier_information_arrays = supplier_holder[@country][@state] if supplier_holder.present?
		@valid_guide = true
	end

end