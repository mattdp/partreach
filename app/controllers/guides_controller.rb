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
			@tags_short = tag.readable
			@tags_long = tag.note

		elsif params[:stipulation_name]
			id_string = params[:stipulation_name]
			@filter = Filter.get(id_string)
			if @filter
				country_long = Word.transform(:shortform,@filter.limits[:countries][0],:longform) #won't work well for international regions
				@location_phrase = "#{country_long}"
				tag_name = nil
				[:and_style_haves,:or_style_haves].each do |have|
					tag_name = @filter.limits[have][0] if @filter.limits[have].length == 1
				end
				tag = Tag.find_by_name(tag_name) if tag_name.present?
			end
		end

		if @filter
			if tag
				@tags_short = tag.readable
				@tags_long = tag.note
			else
				@tags_short = @filter.tags_short
				@tags_long = @filter.tags_long
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