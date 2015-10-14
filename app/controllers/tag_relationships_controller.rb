class TagRelationshipsController < ApplicationController
  before_filter :admin_user
  before_action :org_access_only

  def new
    @organization = current_organization
    @tag_relationship_types_search_list = TagRelationshipType.search_list

    @tag_search_list = Rails.cache.fetch("#{@organization.id}-tag_search_list_id_only-#{@organization.last_provider_update}-#{@organization.last_tag_update}") do
      #same key as providers#index
      tags_with_provider_counts = Rails.cache.fetch("#{@organization.id}-tags_with_provider_counts-#{@organization.last_provider_update}-#{@organization.last_tag_update}") do 
        @organization.tags_with_provider_counts
      end
      Tag.search_list(tags_with_provider_counts,true)
    end 
  end

  def create
    if (
        (params[:source_tag_id].present? and params[:related_tag_id].present? and params[:tag_relationship_type_id].present?) and
        (params[:source_tag_id] != params[:related_tag_id]) and
        (Tag.find(params[:source_tag_id]).organization_id == Tag.find(params[:related_tag_id]).organization_id) and
        (!TagRelationship.where(source_tag_id: params[:source_tag_id], 
          related_tag_id: params[:related_tag_id], 
          tag_relationship_type_id: params[:tag_relationship_type_id]).present?)
        )     
      TagRelationship.create(tag_relationship_params)
      redirect_to new_tag_relationship_path, notice: "Saved OK!"
    else
      redirect_to new_tag_relationship_path, notice: "Failure to save. Check what you submitted."
    end
  end
  
  private

    def tag_relationship_params
      params.permit(:source_tag_id, :related_tag_id, :tag_relationship_type_id)
    end
end