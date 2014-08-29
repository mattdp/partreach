class TagsController < ApplicationController
  before_filter :admin_user

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(tag_params)
    @tag.name_for_link = Tag.proper_name_for_link(params[:name])
    @tag.save

    redirect_to tags_path, notice: "Tag save attempted."
  end

  def edit
    @tag = Tag.find(params[:id])
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.name_for_link = Tag.proper_name_for_link(params[:name])  
    @tag.update_attributes(tag_params)

    redirect_to tags_path, notice: "Tag save attempted."
  end

  def index
    @tags = Tag.all_by_group
  end

  def related_tags
    @tag = Tag.find params[:id]
    @relationships_hash = {}
    relationships = TagRelationshipType.distinct.joins(:tag_relationships).where(tag_relationships: {source_tag_id: @tag.id})
    relationships.each do |relationship|
      related_tags_array = []
      related_tags = Tag.joins(reverse_tag_relationships: :source_tag).where(tag_relationships: {source_tag_id: @tag.id}).where(tag_relationships: {tag_relationship_type_id: relationship.id})
      related_tags.each do |related_tag|
        related_tags_array << related_tag.readable
      end
      @relationships_hash[relationship.name] = related_tags_array
    end
  end

  private

  def tag_params
    params.permit(:tag_group_id,:name,:readable,:note,:exclusive,:visible)
  end

end
