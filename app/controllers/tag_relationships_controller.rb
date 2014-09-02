class TagRelationshipsController < ApplicationController

  # tags/:tag_id/tag_relationships
  def index
    @tag = Tag.find(params[:tag_id])
    @tag_relationships = TagRelationship.joins(:relationship)
      .where('tag_relationships.source_tag_id = ? OR tag_relationships.related_tag_id = ?', @tag.id, @tag.id)
      .joins(:relationship).pluck(:name).uniq
    respond_to do |format|
      format.json { render 'index' }
    end
  end

  def create
    @tag = Tag.find(params[:tag_id])
    @relationship = TagRelationship.new(params[:tag_relationship])

    respond_to do |format|
      if @relationship.save
        format.json { render json: @relationship}
      else
        format.json { render json: {success: false}}
      end
    end
  end
end