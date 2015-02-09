class CommentsController < ApplicationController
  before_filter :hax_access_only

  def new
    @provider = Provider.find(params[:provider_id])
    @comment = Comment.new
    render layout: "provider"
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.comment_type = "comment"
    @comment.user_id = current_user.id
    @comment.save

    saved_ok = @comment.save
    if saved_ok
      note = "Saved OK!" 
    else 
      note = "Saving problem."
    end

    provider = Provider.find(params[:provider_id])
    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

  def comment_params
    params.permit(:overall_score,:payload,:provider_id,:title)
  end

end