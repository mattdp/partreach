class ExperimentsController < ApplicationController

  def show
    @page_name = params[:name]
  end

end