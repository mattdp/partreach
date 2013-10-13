class GuidesController < ApplicationController

	#only works for all of country, state, tag being present and nicely formatted
	def show
		@country = Word.transform(:name_for_link,params[:country],:shortform)
		@country_long = Word.transform(:name_for_link,params[:country],:longform)
		@state = Word.transform(:name_for_link,params[:state],:shortform)
		@state_long = Word.transform(:name_for_link,params[:state],:longform)
		@tag = Tag.find_by_name_for_link(params[:tag_name_for_link])
		@valid_guide = valid_guide?(@country,@state,@tag.name_for_link)
		if @valid_guide
			id_string = "#{@country}-#{@state}-#{@tag.name_for_link}"
			@visibles = Rails.cache.fetch id_string, :expires_in => 25.hours do |key|
				logger.debug "Cache miss: #{id_string}"
				Supplier.visible_profiles_sorted({tcs: {tag: @tag, country: @country, state: @state}})
			end
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