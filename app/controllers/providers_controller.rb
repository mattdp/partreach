class ProvidersController < ApplicationController
  before_filter :hax_access_only, except: :signin
  
  def new
    @provider = Provider.new
    @tags = Provider.providers_hash_by_process.keys
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
   
    new_tags = [params[:new_tag_1],params[:new_tag_2],params[:new_tag_3]]
    saved_ok = @provider.save and @provider.update_tags(params[:tag_selection]) and @provider.tag_creator(new_tags,current_user.id)

    if saved_ok
      note = "Saved OK!" 
    else 
      note = "Saving problem."
    end

    if saved_ok
      Event.add_event("User","#{current_user.id}","created a provider","Provider","#{@provider.id}")
      redirect_to teams_profile_path(@provider.name_for_link)
    else 
      Event.add_event("User","#{current_user.id}","attempted provider create - ERROR")      
      redirect_to teams_index_path, note: note
    end
  end

  def edit
    @provider = Provider.find(params[:id])
    @tags = Provider.providers_hash_by_process.keys
    @checked_tags = @provider.tags

    if params[:event_name].present? 
      Event.add_event("User","#{current_user.id}","#{params[:event_name]}","Provider","#{@provider.id}")
    else
      Event.add_event("User","#{current_user.id}","loaded edit page from unknown source","Provider","#{@provider.id}")
    end

    render layout: "provider"
  end

  def update
    @provider = Provider.find(params[:id])  
    new_tags = [params[:new_tag_1],params[:new_tag_2],params[:new_tag_3]]
    saved_ok = @provider.update(editable_provider_params) and @provider.update_tags(params[:tag_selection]) and @provider.tag_creator(new_tags, current_user.id)

    if saved_ok
      note = "Saved OK!" 
    else 
      note = "Saving problem."
    end

    if saved_ok
      Event.add_event("User","#{current_user.id}","updated a provider","Provider","#{@provider.id}")
      redirect_to teams_profile_path(@provider.name_for_link)
    else 
      Event.add_event("User","#{current_user.id}","attempted provider update - ERROR")      
      redirect_to teams_index_path, note: note
    end    
  end

  def signin
    sign_out
    render layout: "provider"
  end

  def index
    @provider_hash = Provider.providers_hash_by_process
    Event.add_event("User",current_user.id,"loaded index")
    render layout: "provider"
  end

  def profile
    @provider = Provider.find_by_name_for_link(params[:name_for_link])
    @comments = @provider.comments
    @tags = @provider.tags
    @po_names = @comments.select{|c| c.comment_type == "purchase_order"}.map{|c| c.user.lead.lead_contact.first_name_and_team}
    @fv_names = @comments.select{|c| c.comment_type == "factory_visit"}.map{|c| c.user.lead.lead_contact.first_name_and_team}
    Event.add_event("User",current_user.id,"loaded profile","Provider",@provider.id)
    render layout: "provider"
  end

  def suggested_edit
    Event.add_event("User",current_user.id,params[:clicked])
    render layout: "provider"
  end

  private

    def editable_provider_params
      params.permit(:name,:url_main,:contact_qq, \
        :contact_wechat,:contact_phone,:contact_email,:contact_name, \
        :contact_role,:verified,:city,:address,:contact_skype)
    end

end