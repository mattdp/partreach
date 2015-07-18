class CommentsController < ApplicationController
  before_filter :org_access_only, except: [:later]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: [:request_for_review]

  def new_comment
    @comment_type = "comment"
    render_new_comment_form
  end

  def new_factory_visit_comment
    @comment_type = "factory_visit"
    render_new_comment_form
  end

  def new_purchase_order_comment
    @comment_type = "purchase_order"
    render_new_comment_form
  end

  def render_new_comment_form
    @comment = Comment.new
    @provider = Provider.find(params[:provider_id])
    @verbose_type = Comment.verbose_type(@comment_type)
    @flavor = nil    
    Event.add_event("User",current_user.id,"loaded new comment page for","Provider",@provider.id)
    render "new"
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
      if !@comment.any_ratings_given?
        Comment.score_symbols.each do |score|        
          @comment.send("#{score}=",5) 
          @comment.save
        end
      end
    elsif @flavor == "bad"
      Event.add_event("User", @user.id, "said job was bad", "Comment", @comment.id)
      @comment.overall_score = 1 unless @comment.any_ratings_given?
      @comment.save
    end
    
    Event.add_event("User", current_user.id, "loaded edit comment page for", "Comment", @comment.id)
  end

  def update
    # note: @comment initialized in correct_user before_filter
    provider = @comment.provider
    Event.add_event("User", current_user.id, "attempted comment update for", "Comment", @comment.id) 
    note = (@comment.update_attributes(comment_params) ? "Saved OK!" : "Saving problem.")
    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

  def upload_photo
    comment = Comment.find(params[:id])
    bucket_name = current_organization.external_bucket_name
    original_filename = params['filename']
    remote_file_name = params['filepath'].gsub("/#{bucket_name}/", "")

    # change permissions to only allow authenticated access
    s3_resource = External.setup_s3_resource(current_organization)
    file=s3_resource.bucket(bucket_name).object(remote_file_name)
    file.acl.put({ acl: "authenticated-read" })

    #create externals object
    new_external = comment.add_external(original_filename, remote_file_name)

    # get expiring url
    expiring_image_url = 
      new_external.get_expiring_url_helper_generic(s3_resource, comment.provider.organization)

    render plain: expiring_image_url
  end

  def request_for_review
    @comment = Comment.find(params[:id])
    @message_number = params[:message_number]
    @provider = @comment.provider
    @purchase_order = @comment.purchase_order
    @contact = nil
    @contact = @comment.user.lead.lead_contact if (@comment.user.present? and @comment.user.lead.present?)
  end

  def later
    @comment = Comment.find(params[:id])
    @user = @comment.user
    Event.add_event("User", @user.id, "said contact me later", "Comment", @comment.id)
  end

  private

  def comment_params
    params.permit(:overall_score, :quality_score, :cost_score, :speed_score, :payload, :provider_id, :title)
  end

  def correct_user
    @comment = Comment.find params[:id]
    redirect_to teams_index_path unless (@comment.user == current_user or current_user.admin?)
  end

end