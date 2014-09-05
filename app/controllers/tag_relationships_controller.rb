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
    @relationship = TagRelationship.new(tag_relationship_params)

    respond_to do |format|
      if @relationship.save
        format.json { render json: {success: true}}
      else
        format.json { render json: {success: false}}
      end
    end
  end

  private

    def tag_relationship_params
      params.require(:tag_relationship).permit(:source_tag_id, :related_tag_id, :tag_relationship_type_id)
    end
end