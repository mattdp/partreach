class CommentsController < ApplicationController
  before_filter :org_access_only
  before_filter :correct_user, only: [:edit_purchase_order_comment, :update]

  def new_comment
    @comment_type = "comment"
    @comment_type_text = "comment"
    render_new_comment_form
  end

  def new_factory_visit_comment
    @comment_type = "factory_visit"
    @comment_type_text = "factory visit comment"
    render_new_comment_form
  end

  def new_purchase_order_comment
    @comment_type = "purchase_order"
    @comment_type_text = "purchase order comment"
    render_new_comment_form
  end

  def render_new_comment_form
    @comment = Comment.new
    @provider = Provider.find(params[:provider_id])    
    Event.add_event("User",current_user.id,"loaded new comment page for","Provider",@provider.id)
    render "new", layout: "provider"
  end

  def create
    provider = Provider.find(params[:provider_id])
    Event.add_event("User",current_user.id,"attempted comment create for","Provider",provider.id) 
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    if params[:comment_type] == "factory_visit"
      @comment.comment_type = "factory_visit"
    elsif params[:comment_type] == "purchase_order"
      @comment.comment_type = "purchase_order"
    else
      @comment.comment_type = "comment"
    end

    note = (@comment.save ? "Saved OK!" : "Saving problem.")

    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

  def edit_purchase_order_comment
    # note: @comment initialized in correct_user before_filter
    @comment_type_text = "purchase order comment"
    @provider = @comment.provider
    Event.add_event("User", current_user.id, "loaded edit comment page for", "Comment", @comment.id)
    render "edit", layout: "provider"
  end

  def update
    # note: @comment initialized in correct_user before_filter
    provider = @comment.provider
    Event.add_event("User", current_user.id, "attempted comment update for", "Comment", @comment.id) 
    note = (@comment.update_attributes(comment_params) ? "Saved OK!" : "Saving problem.")
    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

  private

  def comment_params
    params.permit(:overall_score, :quality_score, :cost_score, :speed_score, :payload, :provider_id, :title)
  end

  def correct_user
    @comment = Comment.find params[:id]
    redirect_to teams_index_path unless @comment.user == current_user
  end

end