class ProvidersController < ApplicationController

  def index
    @provider_hash = Provider.providers_hash_by_process
  end

  def profile
    @provider = Provider.find_by_name_for_link(params[:name_for_link])
  end

end