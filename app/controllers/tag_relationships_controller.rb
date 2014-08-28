class TagRelationshipsController < ApplicationController

  # tags/:tag_id/tag_relationships
  def index
    @tag = Tag.find(params[:tag_id])
    respond_to |format| do
      format.json { render 'index' }
    end
  end
end