class TagsController < ApplicationController
	before_filter :admin_user

  def new
  	@tag = Tag.new
  	@tag.exclusive = false
  	@tag.visible = true
  end

  def create
  	@tag = Tag.new
  	#handle name for link  	
  end

  def edit
  	@tag = Tad.find(params[:id])
  end

  def update
  	@tag = Tad.find(params[:id])
  	#handle name for link
  end

  def index
  	tags = Tag.all
  end

  private

  	def tag_params
  		params.permit(:name,:family,:readable,:note,:exclusive,:visible)
  	end

end
