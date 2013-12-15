class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show

		@filter = Filter.find_by_name(params[:name])

		if @filter

			@location_phrase = @filter.geography.long_name

			tag = Tag.find(@filter.has_tag_id)

			@tags_short = tag.readable
			@tags_long = tag.note

			@adjacencies = Rails.cache.fetch "#{@filter.name}-adjacencies", :expires_in => 25.hours do |key|
				logger.debug "Cache miss: #{@filter.name}-adjacencies"
				@filter.adjacencies
			end

			@visibles, @supplier_count = Rails.cache.fetch @filter.name, :expires_in => 25.hours do |key|
				logger.debug "Cache miss: #{@filter.name}"
				Supplier.visible_profiles_sorted(@filter)
			end
		end
		
	end

end