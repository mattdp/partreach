class WebSearchItemsController < ApplicationController
  before_action :set_web_search_item, only: [:show, :edit, :update, :destroy]

  # GET /web_search_items
  def index
    @web_search_items = WebSearchItem.queued
  end

  # GET /web_search_items/new
  def new
    @web_search_item = WebSearchItem.new
  end

  # GET /web_search_items/1/edit
  def edit
  end

  # POST /web_search_items
  def create
    @web_search_item = WebSearchItem.new(web_search_item_params)
    @web_search_item.priority ||= WebSearchItem::DEFAULT_PRIORITY
    if @web_search_item.save
      redirect_to web_search_items_path, notice: 'Web search item was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /web_search_items/1
  def update
    params = web_search_item_params
    params[:priority] = WebSearchItem::DEFAULT_PRIORITY if params[:priority].blank?
    if @web_search_item.update(params)
      redirect_to web_search_items_path, notice: 'Web search item was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /web_search_items/1
  def destroy
    @web_search_item.destroy
    redirect_to web_search_items_path, notice: 'Web search item was successfully deleted.'
  end

  def upload
    uploaded_file = params[:file]
    priority = params[:priority].blank? ? WebSearchItem::DEFAULT_PRIORITY : params[:priority]
    num_requested = params[:num_requested]

    if uploaded_file
      search_items = uploaded_file.open
      search_items.each do |line|
        WebSearchItem.add_item(line, priority, num_requested)
      end
    end

    redirect_to web_search_items_path, notice: 'Web search item list was successfully uploaded.'
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_web_search_item
      @web_search_item = WebSearchItem.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def web_search_item_params
      params.require(:web_search_item).permit(:query, :priority, :num_requested)
    end
end
