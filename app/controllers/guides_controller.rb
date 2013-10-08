class GuidesController < ApplicationController

	def show
		@state = params[:state]
		@tag = Tag.find_by_name_for_link(params[:tag_name])
	end

end