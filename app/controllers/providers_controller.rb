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
    @org = current_organization

    @people_called = @org.colloquial_people_name

    @providers_list = Rails.cache.fetch("#{current_organization.id}-providers_alpha_sort-#{Provider.maximum(:updated_at)}") do 
      @org.providers_alpha_sort
    end

    @provider_hash = Rails.cache.fetch("#{current_organization.id}-providers_hash_by_tag-#{Provider.maximum(:updated_at)}-#{Tagging.maximum(:updated_at)}") do 
      @org.providers_hash_by_tag
    end

    @recent_activity = Rails.cache.fetch("#{current_organization.id}-recent_activity-#{Provider.maximum(:updated_at)}-#{Comment.maximum(:updated_at)}-#{PurchaseOrder.maximum(:updated_at)}") do 
      @org.recent_activity
    end

    @providers_tag_search_list = []
    @provider_hash.each { |tag, providers| @providers_tag_search_list << [providers.size, tag.readable] }
    @providers_tag_search_list.sort_by! {|e| [-(e[0]), e[1].downcase]}
    @providers_tag_search_list.each { |e| e[0] = "#{e[1]} [#{e[0]} #{"company".pluralize(e[0])}]" }

    @results_hash = {}
    if params[:tags].present?
      Event.add_event("User", current_user.id, "searched providers by tags", nil, nil, @search_text)
      tags = []
      params[:tags].each do |unsafe_string|
        possible_tag = Tag.where("organization_id = ? and readable = ?",current_organization,unsafe_string)
        tags << possible_tag[0] if possible_tag.present?
      end

      #adapted from organization.providers_hash_by_tag
      tags.sort_by { |t| t.readable.downcase }.each do |tag|
        @results_hash[tag.readable] = Provider.joins('INNER JOIN taggings ON taggings.taggable_id = providers.id')
          .where("taggable_type = ? and tag_id = ?","Provider",tag.id)
          .order("lower(name)")
      end

      @search_text = tags.map{|t| t.readable}.join(" & ")
    elsif params[:providers].present?
      Event.add_event("User", current_user.id, "searched providers by provider names", nil, nil, @search_text)
      providers = []
      params[:providers].each do |unsafe_string|
        possible_provider = Provider.find_by_name(unsafe_string)
        providers << possible_provider if possible_provider.present?
      end

      @results_hash["Providers"] = providers
      
      @search_text = providers.map{|p| p.name}.join(" & ")
    else
      Event.add_event("User",current_user.id,"loaded Providers index page")
    end
  end

  def profile
    @provider = current_organization.providers.find_by_name_for_link(params[:name_for_link])
    if @provider
      @organization = current_organization
      @comments = Comment.where(provider_id: @provider.id).order(helpful_count: :desc, created_at: :desc)
      @total_comments_for_user = Comment.joins(:user).group('users.id').count
      @purchase_order_comments_for_user = Comment.where(comment_type: 'purchase_order').joins(:user).group('users.id').count
      @tags = @provider.tags.sort_by { |t| t.readable.downcase }
      @po_names_and_counts = @provider.po_names_and_counts
      @fv_names = @comments.select{|c| c.comment_type == "factory_visit"}.map{|c| c.user.lead.lead_contact.first_name_and_team}
      
      @expiring_image_urls = External.get_expiring_urls(@provider.externals,@organization)

      Event.add_event("User",current_user.id,"loaded profile","Provider",@provider.id)
    else
      render template: "providers/profile_not_found"
    end
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
    expiring_image_url = new_external.get_expiring_url_helper(s3_resource)

    render plain: expiring_image_url
  end

  private

    def editable_provider_params
      params.permit(:name,:url_main, \
        :contact_wechat,:contact_phone,:contact_email,:contact_name,:contact_skype, \
        :contact_role,:location_string,:external_notes,:organization_private_notes)
    end

end