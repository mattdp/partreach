class ProvidersController < ApplicationController
  before_filter :admin_user

  include SessionsHelper
  
  def index
    @provider_hash = Provider.providers_hash_by_process
    render layout: "orders_new"
  end

  def profile
    @provider = Provider.find_by_name_for_link(params[:name_for_link])
    @comments = @provider.comments
    Event.add_event("User",current_user.id,"loaded profile","Provider",@provider.id)
    render layout: "orders_new"
  end

end