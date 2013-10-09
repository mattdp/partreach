class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show
		@country = Word.transform(:name_for_link,params[:country],:shortform)
		@state = Word.transform(:name_for_link,params[:state],:shortform)
		@state_long = Word.transform(:name_for_link,params[:state],:longform)
		@tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
		@valid_guide = valid_guide?(@country,@state,@tag.name_for_link)
		if @valid_guide
			supplier_holder = Supplier.visible_profiles_sorted(nil,@tag,@country,@state)
			@supplier_information_arrays = supplier_holder[@country][@state] if supplier_holder.present?
		end
	end

	private

		def valid_guide?(country,state,tag_name)
			comparitor = [country,state,tag_name]
			return comparitor.in?([
				["US","CA","3dprinting"]
			])
		end

end