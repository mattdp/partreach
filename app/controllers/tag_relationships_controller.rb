class TagRelationshipsController < ApplicationController

  # tags/:tag_id/tag_relationships
  def index
    @tag = Tag.find(params[:tag_id])
    @tag_relationships = TagRelationship.joins(:relationship).where(source_tag_id: @tag.id).joins(:relationship).pluck(:name).uniq
    respond_to do |format|
      format.json { render 'index' }
    end
  end
end