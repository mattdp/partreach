class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show

		if params[:name]
			id_string = params[:name]
		elsif (params[:country] and params[:country] == "unitedstates" and params[:state] and params[:tags_string])
			country = "US"
			state = Word.transform(:name_for_link,params[:state],:shortform)
			id_string = Filter.name_formatter(country,state,params[:tags_string])
		else
			id_string = nil
		end

		@filter = Filter.get(id_string)

		if @filter
			country_long = Word.transform(:shortform,@filter.limits[:countries][0],:longform) #won't work well for international regions
			@location_phrase = "#{country_long}"
			tag_name = nil
			[:and_style_haves,:or_style_haves].each do |have|
				tag_name = @filter.limits[have][0] if @filter.limits[have].length == 1
			end
			tag = Tag.find_by_name(tag_name) if tag_name.present?

			if tag
				@tags_short = tag.readable
				@tags_long = tag.note
			else
				@tags_short = @filter.tags_short
				@tags_long = @filter.tags_long
			end

			@visibles, @supplier_count = Rails.cache.fetch id_string, :expires_in => 25.hours do |key|
				logger.debug "Cache miss: #{id_string}"
				Supplier.visible_profiles_sorted(@filter)
			end
		end
		
	end

end