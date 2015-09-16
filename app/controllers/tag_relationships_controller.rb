class TagRelationshipsController < ApplicationController
  before_action :org_access_only

  def new
    @organization = current_organization
    #same cache keys as providers#index 
    @tag_search_list = Rails.cache.fetch("#{@organization.id}-tag_search_list-#{@organization.last_provider_update}-#{@organization.last_tag_update}") do
      sorted_tags_by_providers = Rails.cache.fetch("#{@organization.id}-providers_hash_by_tag-#{@organization.last_provider_update}-#{@organization.last_tag_update}") do 
        @organization.sorted_tags_by_providers
      end
      Tag.search_list(sorted_tags_by_providers)
    end 
  end
  
  private

    def tag_relationship_params
      params.require(:tag_relationship).permit(:source_tag_id, :related_tag_id, :tag_relationship_type_id)
    end
end