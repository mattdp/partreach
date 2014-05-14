class TagsController < ApplicationController
	before_filter :admin_user

  def new
  	@tag = Tag.new
  	@tag.exclusive = false
  	@tag.visible = true
  end

  def create
  	@tag = Tag.new
		@tag.name_for_link = Tag.proper_name_for_link(params[:name])
		@tag.update_attributes(tag_params)

		redirect_to tags_path, notice: "Tag save attempted."
  end

  def edit
  	@tag = Tag.find(params[:id])
  end

  def update
  	@tag = Tag.find(params[:id])
 		@tag.name_for_link = Tag.proper_name_for_link(params[:name]) 	
  	@tag.update_attributes(tag_params)

  	redirect_to tags_path, notice: "Tag save attempted."
  end

  def index
  	@tags = Tag.all
  end

  private

  	def tag_params
  		params.permit(:name,:family,:readable,:note,:exclusive,:visible)
  	end

end
