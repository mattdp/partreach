class ProvidersController < ApplicationController

  def index
    @provider_hash = Provider.providers_hash_by_process
  end

  def show
  end

end