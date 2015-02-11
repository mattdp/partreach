class CommentsController < ApplicationController
  before_filter :hax_access_only

  def new
    @provider = Provider.find(params[:provider_id])    
    Event.add_event("User",current_user.id,"loaded new comment page for","Provider",@provider.id)
    @comment = Comment.new
    render layout: "provider"
  end

  def create
    provider = Provider.find(params[:provider_id])
    Event.add_event("User",current_user.id,"attempted comment create for","Provider",provider.id) 
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

    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

  def comment_params
    params.permit(:overall_score,:payload,:provider_id,:title)
  end

end