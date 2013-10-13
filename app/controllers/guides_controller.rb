class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show
		@country = Word.transform(:name_for_link,params[:country],:shortform)
		@country_long = Word.transform(:name_for_link,params[:country],:longform)
		@state = Word.transform(:name_for_link,params[:state],:shortform)
		@state_long = Word.transform(:name_for_link,params[:state],:longform)
		@tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
		id_string = "#{@country}-#{@state}-#{@tag.name}"
		@filter = Filter.get(id_string)
		if @filter
			@visibles, @supplier_count = Rails.cache.fetch id_string, :expires_in => 25.hours do |key|
				logger.debug "Cache miss: #{id_string}"
				Supplier.visible_profiles_sorted(@filter)
			end
		end
	end

end