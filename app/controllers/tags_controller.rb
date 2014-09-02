class TagsController < ApplicationController
  before_filter :admin_user

  def show
    @tag = Tag.find(params[:id])
    @process_tags = Tag.where(tag_group_id: @tag.tag_group_id)

    respond_to do |format|
      format.json { render 'show' }
    end
  end

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
    @tag_relationships = TagRelationship.joins(:relationship).where(source_tag_id: @tag.id).joins(:relationship).pluck(:name).uniq
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

  def related_tags
    @tag = Tag.find(params[:id])
    @relationships_hash = TagRelationship.related_tags_by_relationship(@tag.id)
  end

  private

  def tag_params
    params.permit(:tag_group_id,:name,:readable,:note,:exclusive,:visible)
  end

end
