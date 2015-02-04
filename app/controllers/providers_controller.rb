class ProvidersController < ApplicationController
  before_filter :admin_user

  def index
    @provider_hash = Provider.providers_hash_by_process
    render layout: "orders_new"

  end

  def profile
    @provider = Provider.find_by_name_for_link(params[:name_for_link])
    render layout: "orders_new"
  end

end