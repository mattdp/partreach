class ProvidersController < ApplicationController
  before_action :org_access_only, except: :signin
  skip_before_action :allow_staging_access, only: :signin

  def new
    @provider = Provider.new
    @tags = current_organization.provider_tags
    @organization = current_organization    
    @checked_tags = []

    if params[:event_name].present? 
      Event.add_event("User","#{current_user.id}","#{params[:event_name]}")
    else
      Event.add_event("User","#{current_user.id}","loaded new profile page from unknown source")
    end

    render layout: "provider"
  end

  def create
    @provider = Provider.new(editable_provider_params)
    @provider.name_for_link = Provider.proper_name_for_link(@provider.name)
    @provider.source = "User #{current_user.id}"
    @provider.organization = current_organization
    create_or_update_provider
  end

  def edit
    @provider = current_organization.providers.find(params[:id])
    @tags = current_organization.provider_tags
    @organization = current_organization
    @checked_tags = @provider.tags

    if params[:event_name].present? 
      Event.add_event("User","#{current_user.id}","#{params[:event_name]}","Provider","#{@provider.id}")
    else
      Event.add_event("User","#{current_user.id}","loaded edit page from unknown source","Provider","#{@provider.id}")
    end

    render layout: "provider"
  end

  def update
    @provider = current_organization.providers.find(params[:id])
    create_or_update_provider
  end

  def create_or_update_provider
    saved_ok = false
    loop do
      @provider.assign_attributes(editable_provider_params) #returns nil
      break unless @provider.save
      break unless @provider.update_tags(params[:tag_selection])
      new_tag_names = [params[:new_tag_1],params[:new_tag_2],params[:new_tag_3]].select {|tag_name| tag_name.present? }
      new_tag_names.each do |tag_name|
        tag = current_organization.find_existing_tag(tag_name)
        unless tag
          tag = current_organization.create_tag(tag_name, current_user)
        end
        break unless tag.valid?
        @provider.tags << tag
      end

      saved_ok = true
      break
    end

    if saved_ok
      Event.add_event("User","#{current_user.id}","created a provider","Provider","#{@provider.id}")
      redirect_to teams_profile_path(@provider.name_for_link), note: "Saved OK!" 
    else 
      Event.add_event("User","#{current_user.id}","attempted provider create - ERROR")      
      redirect_to teams_index_path, note: "Saving problem."
    end
  end

  def create_tag
    if params[:new_tag].present?
      new_tag = current_organization.create_tag(params[:new_tag], current_user)

      if new_tag.valid?
        note = "Saved OK!" 
      else 
        note = "Saving problem."
      end
    end

    redirect_to teams_index_path, note: note
  end

  def signin
    sign_out
    render layout: "provider"
  end

  def index
    @provider_hash = current_organization.providers_hash_by_tag
    Event.add_event("User",current_user.id,"loaded index")
    render layout: "provider"
  end

  def search_results
    if @tag_filters = params[:tags]
      @provider_tags = current_organization.provider_tags
      @providers = current_organization.providers.
                   joins(taggings: :tag).where(tags: {readable: @tag_filters}).
                   group('providers.id').having("count(*) >= #{@tag_filters.size}")
      Event.add_event("User", current_user.id, "searched providers by tags", nil, nil, @tag_filters.join(" & "))
      render layout: "provider"
    else
      redirect_to teams_index_path
    end
  end

  def profile
    @provider = current_organization.providers.find_by_name_for_link(params[:name_for_link])
    if @provider
      @organization = current_organization
      @comments = Comment.where(provider_id: @provider.id).order(helpful_count: :desc, created_at: :desc)
      @total_comments_for_user = Comment.joins(:user).group('users.id').count
      @purchase_order_comments_for_user = Comment.where(comment_type: 'purchase_order').joins(:user).group('users.id').count
      @tags = @provider.tags
      @po_names = @comments.select{|c| c.comment_type == "purchase_order"}.map{|c| c.user.lead.lead_contact.first_name_and_team}
      @fv_names = @comments.select{|c| c.comment_type == "factory_visit"}.map{|c| c.user.lead.lead_contact.first_name_and_team}
      Event.add_event("User",current_user.id,"loaded profile","Provider",@provider.id)
      render layout: "provider"
    else
      render template: "providers/profile_not_found", layout: "provider"
    end
  end

  def suggested_edit
    Event.add_event("User",current_user.id,params[:clicked])
    render layout: "provider"
  end

  def upload_photo
    provider = current_organization.providers.find(params[:provider_id])
    provider.add_external(params['url'], params['filename'])
    render nothing: true
  end

  private

    def editable_provider_params
      params.permit(:name,:url_main, \
        :contact_wechat,:contact_phone,:contact_email,:contact_name, \
        :contact_role,:address,:external_notes,:organization_private_notes)
    end

end