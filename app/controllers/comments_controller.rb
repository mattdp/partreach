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
    @comment = Comment.new(recommendation: "none")
    @provider = Provider.find(params[:provider_id])
    @verbose_type = Comment.verbose_type(@comment_type)
    @projects_listing = current_organization.projects_for_listing
    @default_project = nil
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

    project = Project.where(name: params[:project], organization_id: current_organization.id)
    if params[:new_project].present?
      @comment.project_id = Project.find_or_create(current_organization.id, params[:new_project]).id
    elsif project.present? #checking for a non-default option
      @comment.project_id = project[0].id
    end

    begin
      @comment.save!
      add_externals
      @comment.save
      note = "Saved OK!"
    rescue ActiveRecord::ActiveRecordError
      note = "Saving problem."
    end

    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

  def edit
    # note: @comment initialized in correct_user before_filter
    @verbose_type = Comment.verbose_type(@comment.comment_type)
    @provider = @comment.provider
    @user = @comment.user
    @projects_listing = current_organization.projects_for_listing
    @comment.project.present? ? @default_project = @comment.project.name : @default_project = nil
    @comment_photo_urls = External.get_expiring_urls(@comment.externals, current_organization)

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
    elsif @flavor == "between"
      Event.add_event("User", @user.id, "said job was in between", "Comment", @comment.id)
    end
    
    Event.add_event("User", current_user.id, "loaded edit comment page for", "Comment", @comment.id)
  end

  def update
    # note: @comment initialized in correct_user before_filter
    provider = @comment.provider
    Event.add_event("User", current_user.id, "attempted comment update for", "Comment", @comment.id) 

    # create externals and associate with comment
    add_externals

    if params[:new_project].present?
      @comment.project_id = Project.find_or_create(current_organization.id, params[:new_project]).id
    elsif params[:project] == Project.none_selected
      @comment.project_id = nil
    else
      @comment.project_id = Project.find_or_create(current_organization.id, params[:project]).id
    end

    note = (@comment.update_attributes(comment_params) ? "Saved OK!" : "Saving problem.")
    redirect_to teams_profile_path(provider.name_for_link), notice: note
  end

  def add_externals
    # create externals and associate with comment
    if params["comment_uploads"]
      params["comment_uploads"].each do |upload|
        bucket_name = current_organization.external_bucket_name
        @comment.externals.build(
          url: '#',
          original_filename: upload['filename'],
          remote_file_name: upload['filepath'].gsub("/#{bucket_name}/", "")
          )
      end
    end
  end

  def upload_photo
    bucket_name = current_organization.external_bucket_name
    original_filename = params['filename']
    remote_file_name = params['filepath'].gsub("/#{bucket_name}/", "")

    # change permissions to only allow authenticated access
    s3_resource = External.setup_s3_resource(current_organization)
    file=s3_resource.bucket(bucket_name).object(remote_file_name)
    file.acl.put({ acl: "authenticated-read" })

    # get expiring url for newly uploaded file, to allow browser to gain temporary access
    expiring_image_url =
      External.get_s3_expiring_url(
        s3_resource, current_organization.external_bucket_name, remote_file_name)

    render json: { expiring_image_url: expiring_image_url }
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
    params.permit(:overall_score, :quality_score, :cost_score, :speed_score, :payload, \
      :provider_id, :title, :recommendation)
  end

  def correct_user
    @comment = Comment.find params[:id]
    redirect_to teams_index_path unless (@comment.user == current_user or current_user.admin?)
  end

end