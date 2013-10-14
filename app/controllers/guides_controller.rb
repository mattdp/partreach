class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show
		if params[:country] and params[:state] and params[:tag_name_for_link]
			@country = Word.transform(:name_for_link,params[:country],:shortform)
			@country_long = Word.transform(:name_for_link,params[:country],:longform)
			@state = Word.transform(:name_for_link,params[:state],:shortform)
			@state_long = Word.transform(:name_for_link,params[:state],:longform)
			@tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
			id_string = "#{@country}-#{@state}-#{@tag.name}"
			@filter = Filter.get(id_string)
		end #put in elsif for index of country/tag OR make that a CST.
		if @filter
			@visibles, @supplier_count = Rails.cache.fetch id_string, :expires_in => 25.hours do |key|
				logger.debug "Cache miss: #{id_string}"
				Supplier.visible_profiles_sorted(@filter)
			end
		end
	end

end