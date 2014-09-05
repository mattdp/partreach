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
    @tag_relationships = TagRelationship
      .joins(:relationship)
      .where('tag_relationships.source_tag_id = ? OR tag_relationships.related_tag_id = ?', @tag.id, @tag.id)
      .joins(:relationship).pluck(:name).uniq
    gon.tag_id = @tag.id
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


  private

  def tag_params
    params.permit(:tag_group_id,:name,:readable,:note,:exclusive,:visible)
  end

end
