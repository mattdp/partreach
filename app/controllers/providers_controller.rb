class ProvidersController < ApplicationController
  before_filter :hax_access_only, except: :signin
  
  def new
    @provider = Provider.new
    render layout: "provider"
  end

  def create
  end

  def edit
    @provider = Provider.find(params[:id])
    render layout: "provider"
  end

  def update
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

end