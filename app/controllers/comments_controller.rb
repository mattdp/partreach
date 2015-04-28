class CommentsController < ApplicationController
  before_filter :org_access_only, except: [:later]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: [:request_for_review]

  def new_comment
    @comment_type = "comment"
    @verbose_type = Comment.verbose_type(@comment_type)
    render_new_comment_form
  end

  def new_factory_visit_comment
    @comment_type = "factory_visit"
    @verbose_type = Comment.verbose_type(@comment_type)
    render_new_comment_form
  end

  def new_purchase_order_comment
    @comment_type = "purchase_order"
    @verbose_type = Comment.verbose_type(@comment_type)
    render_new_comment_form
  end

  def render_new_comment_form
    @comment = Comment.new
    @provider = Provider.find(params[:provider_id])
    @flavor = nil    
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

  def edit
    # note: @comment initialized in correct_user before_filter
    @verbose_type = Comment.verbose_type(@comment.comment_type)
    @provider = @comment.provider
    @user = @comment.user

    @flavor = params[:flavor]
    if @flavor == "good"
      Event.add_event("User", @user.id, "said job was good", "Comment", @comment.id)
    elsif @flavor == "bad"
      Event.add_event("User", @user.id, "said job was bad", "Comment", @comment.id)
    end
    
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

  def request_for_review
    @comment = Comment.find(params[:id])
    render layout: "provider"
  end

  def later
    @comment = Comment.find(params[:id])
    @user = @comment.user
    Event.add_event("User", @user.id, "said contact me later", "Comment", @comment.id)
    render layout: "provider"
  end

  private

  def comment_params
    params.permit(:overall_score, :quality_score, :cost_score, :speed_score, :payload, :provider_id, :title)
  end

  def correct_user
    @comment = Comment.find params[:id]
    redirect_to teams_index_path unless (@comment.user == current_user or @comment.user.admin)
  end

end