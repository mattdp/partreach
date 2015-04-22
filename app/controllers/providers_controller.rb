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
    @providers_list = current_organization.providers_alpha_sort
    @provider_hash = current_organization.providers_hash_by_tag

    @providers_tag_search_list = []
    @provider_hash.each { |key, value| @providers_tag_search_list << [value.size, key.name] }
    @providers_tag_search_list.sort_by! {|e| [-(e[0]), e[1].downcase]}
    @providers_tag_search_list.each { |e| e[0] = "#{e[1]} [#{e[0]} providers]" }

    Event.add_event("User",current_user.id,"loaded index")
    render layout: "provider"
  end

  def search_results
    if params[:tags].present?
      tags = []
      params[:tags].each do |unsafe_string|
        possible_tag = Tag.find_by_readable(unsafe_string)
        tags << possible_tag if possible_tag.present?
      end

      #adapted from organization.providers_hash_by_tag
      @results_hash = {}
      tags.sort_by { |t| t.readable.downcase }.each do |tag|
        @results_hash[tag.readable] = Tagging.where("taggable_type = ? and tag_id = ?","Provider",tag.id).map{|tg| Provider.find(tg.taggable_id)}
      end

      @search_text = tags.map{|t| t.readable}.join(" & ")
      Event.add_event("User", current_user.id, "searched providers by tags", nil, nil, @search_text)
      render layout: "provider"

    elsif params[:providers].present?
      providers = []
      params[:providers].each do |unsafe_string|
        possible_provider = Provider.find_by_name(unsafe_string)
        providers << possible_provider if possible_provider.present?
      end

      @results_hash = {}
      @results_hash["Providers"] = providers
      
      @search_text = providers.map{|p| p.name}.join(" & ")
      Event.add_event("User", current_user.id, "searched providers by provider names", nil, nil, @search_text)
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
        :contact_role,:location_string,:external_notes,:organization_private_notes)
    end

end