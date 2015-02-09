class CommentsController < ApplicationController
  before_filter :hax_access_only

  def new
    @provider = Provider.find(params[:provider_id])
    @comment = Comment.new
    render layout: "provider"
  end

  def create
    #comment_type
    #user_id
  end

end