class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show
		if params[:country] and params[:state] and params[:tag_name_for_link]
			country = Word.transform(:name_for_link,params[:country],:shortform)
			state = Word.transform(:name_for_link,params[:state],:shortform)
			tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
			country_long = Word.transform(:name_for_link,params[:country],:longform)
			state_long = Word.transform(:name_for_link,params[:state],:longform)

			id_string = "#{country}-#{state}-#{tag.name}"
			@filter = Filter.get(id_string)

			state.present? ? @location_phrase = "#{state_long} (#{country_long})" : @location_phrase = "#{country_long}"
			@tags_name = tag.readable
			@tags_note = tag.note

		elsif params[:stipulation_name]
			id_string = params[:stipulation_name]
			@filter = Filter.get(id_string)
			if @filter
				country_long = Word.transform(:shortform,@filter.limits[:countries][0],:longform) #won't work well for international regions
				@location_phrase = "#{country_long}"
				@tags_name = "TEST FIX THIS"
				@tags_note = "TEST ALSO FIX THIS"
			end
		end
		if @filter
			@visibles, @supplier_count = Rails.cache.fetch id_string, :expires_in => 25.hours do |key|
				logger.debug "Cache miss: #{id_string}"
				Supplier.visible_profiles_sorted(@filter)
			end
		end
	end

end