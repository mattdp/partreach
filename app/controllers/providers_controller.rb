class ProvidersController < ApplicationController
  before_action :org_access_only, except: :signin
  skip_before_action :allow_staging_access, only: :signin

  def new
    @organization = current_organization
    @provider = Provider.new
    @tags = current_organization.provider_tags.sort_by { |t| t.readable.downcase }
    @checked_tags = []
    @contact_fields = Provider.contact_fields

    if params[:event_name].present? 
      Event.add_event("User","#{current_user.id}","#{params[:event_name]}")
    else
      Event.add_event("User","#{current_user.id}","loaded new profile page from unknown source")
    end
  end

  def create
    @provider = Provider.new(editable_provider_params)
    @provider.name_for_link = Provider.proper_name_for_link(@provider.name)
    @provider.source = "User #{current_user.id}"
    @provider.organization = current_organization
    create_or_update_provider
  end

  def edit
    @organization = current_organization
    @provider = current_organization.providers.find(params[:id])
    @tags = current_organization.provider_tags.sort_by { |t| t.readable.downcase }
    @checked_tags = @provider.tags
    @contact_fields = Provider.contact_fields

    if params[:event_name].present? 
      Event.add_event("User","#{current_user.id}","#{params[:event_name]}","Provider","#{@provider.id}")
    else
      Event.add_event("User","#{current_user.id}","loaded edit page from unknown source","Provider","#{@provider.id}")
    end
  end

  def update
    @provider = current_organization.providers.find(params[:id])
    create_or_update_provider
  end

  def create_or_update_provider
    saved_ok = false
    @provider.id.present? ? http_verb = "update" : http_verb = "create"
    loop do
      # TODO wrap this in a db transaction
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
        @provider.tags << tag unless @provider.tags.include? tag
      end

      saved_ok = true
      break
    end

    if saved_ok
      Event.add_event("User","#{current_user.id}","#{http_verb}d a provider","Provider","#{@provider.id}")
      redirect_to teams_profile_path(@provider.name_for_link), note: "Saved OK!" 
    else 
      Event.add_event("User","#{current_user.id}","attempted provider #{http_verb} - ERROR")
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

  def index
    @organization = current_organization

    @people_called = @organization.colloquial_people_name
    @purchase_order_titles = @organization.has_any_pos?

    @providers_list = Rails.cache.fetch("#{@organization.id}-providers_alpha_sort-#{@organization.last_provider_update}") do 
      temp_list = []
      @organization.providers_alpha_sort.each do |provider|
        temp_list << [provider.name, "P:#{provider.id}"]
      end
      temp_list
    end

    #needed in two places below
    sorted_tags_by_providers = Rails.cache.fetch("#{@organization.id}-providers_hash_by_tag-#{@organization.last_provider_update}-#{@organization.last_tag_update}") do 
      stbp = []
      @organization.providers_hash_by_tag.each { |tag, providers| stbp << [providers.size, tag] }
      stbp = stbp.sort_by! {|e| [-(e[0]), e[1].readable.downcase]}
    end

    #order sensitive - 1 of 2 - s_t_b_p manipulated by @p_t_s_l, and cloning didn't seem to stop it
    @common_search_tags = Rails.cache.fetch("#{@organization.id}-common_search_tags-#{@organization.last_provider_update}-#{@organization.last_tag_update}") do 
      min_list_length = 5      
      @organization.common_search_tags(sorted_tags_by_providers.take(min_list_length))
    end

    #order sensitive - 2 of 2
    @providers_tag_search_list = Rails.cache.fetch("#{@organization.id}-providers_tag_search_list-#{@organization.last_provider_update}-#{@organization.last_tag_update}") do 
      sorted_tags_by_providers.each do |e|
        e[0] = "#{e[1].readable} [#{e[0]} #{"company".pluralize(e[0])}]"
        e[1] = "T:#{e[1]}"
      end
    end

    @search_terms_list = @providers_list + @providers_tag_search_list

    @recent_activity = Rails.cache.fetch("#{@organization.id}-recent_activity-#{@organization.last_provider_update}") do 
      @organization.recent_activity(["comments","providers"])
    end

    @recent_recommendations = Rails.cache.fetch("#{@organization.id}-recent_recommendations-#{@organization.last_provider_update}") do 
      @organization.recent_activity(["comments"],true)
    end

    @results_hash = {}

    if params[:search_terms].present?

      tag_terms = params[:search_terms].select { |term| term[0] == 'T' }
      if tag_terms.present?
        readables = []
        tag_terms.each do |term|
          readables << term[2..term.length]
        end
        tags = Tag.where(organization_id: current_organization).where(readable: readables)
        #adapted from organization.providers_hash_by_tag
        tags.sort_by { |t| t.readable.downcase }.each do |tag|
          @results_hash[tag.readable] = Provider.joins('INNER JOIN taggings ON taggings.taggable_id = providers.id')
            .where("taggable_type = ? and tag_id = ?","Provider",tag.id)
            .order("lower(name)")
        end
        # @search_text = tags.map{|t| t.readable}.join(" & ")
        # Event.add_event("User", current_user.id, "searched providers by tags", nil, nil, @search_text)
      end

      provider_terms = params[:search_terms].select { |term| term[0] == 'P' }
      if provider_terms.present?
        ids = []
        provider_terms.each do |term|
          ids << term[2..term.length].to_i
        end
        providers = Provider.where(id: ids)
        # sort by name???
        @results_hash["Providers"] = providers
        # @search_text = providers.map{|p| p.name}.join(" & ")
        # Event.add_event("User", current_user.id, "searched providers by provider names", nil, nil, @search_text)
      end

      # if only one provider, skip list, just display that provider's profile page
      # redirect_to teams_profile_path(providers[0].name_for_link) if providers.size == 1
     
    else
      Event.add_event("User",current_user.id,"loaded Providers index page")
    end
  end

  def profile
    @provider = current_organization.providers.find_by_name_for_link(params[:name_for_link])
    if @provider
      @organization = current_organization
      
      all_comments = Comment.where(provider_id: @provider.id).order(helpful_count: :desc, created_at: :desc)
      @comments = all_comments.reject{|c| c.untouched?}.concat(all_comments.select{|c| c.untouched?})
       
      @comment_photo_urls_hash = init_comment_photo_urls_hash(@comments)
      @total_comments_for_user = Comment.joins(:user).group('users.id').count
      @purchase_order_comments_for_user = Comment.where(comment_type: 'purchase_order').joins(:user).group('users.id').count
      @tags = @provider.tags.sort_by { |t| t.readable.downcase }
      @po_names_and_counts = @provider.po_names_and_counts
      @fv_names = @comments.select{|c| c.comment_type == "factory_visit"}.map{|c| c.user.lead.lead_contact.first_name_and_team}
      
      @profile_photo_urls = External.get_expiring_urls(@provider.externals,@organization)

      Event.add_event("User",current_user.id,"loaded profile","Provider",@provider.id)
    else
      render template: "providers/profile_not_found"
    end
  end

  def init_comment_photo_urls_hash(comments)
    @comment_photo_urls_hash = {}
    comments.each do |comment|
      @comment_photo_urls_hash[comment.id] =
        External.get_expiring_urls(comment.externals, current_organization)
    end
    @comment_photo_urls_hash
  end

  def suggested_edit
    Event.add_event("User",current_user.id,params[:clicked])
  end

  def upload_photo
    provider = current_organization.providers.find(params[:provider_id])
    bucket_name = current_organization.external_bucket_name
    original_filename = params['filename']
    remote_file_name = params['filepath'].gsub("/#{bucket_name}/", "")

    # change permissions to only allow authenticated access
    s3_resource = External.setup_s3_resource(current_organization)
    file=s3_resource.bucket(bucket_name).object(remote_file_name)
    file.acl.put({ acl: "authenticated-read" })

    #create externals object
    new_external = provider.add_external(original_filename, remote_file_name)
    expiring_image_url = External.get_s3_expiring_url(
      s3_resource, current_organization.external_bucket_name, remote_file_name)

    render plain: expiring_image_url
  end

  private

    def editable_provider_params
      params.permit(:name,:url_main, \
        :contact_wechat,:contact_phone,:contact_email,:contact_name,:contact_skype, \
        :contact_role,:location_string,:external_notes,:organization_private_notes)
    end

end